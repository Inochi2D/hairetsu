/**
    Hairetsu Font Reader interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.reader;
import hairetsu.font.file;
import nulib.collections;
import nulib.io.stream.rw;
import nulib.io.stream;
import nulib.math.fixed;
import nulib.text.unicode;
import nulib.string;

import numem.core.traits : Fields, isStructLike;
import numem;

/**
    A factory for constructing a font reader and
    querying 
*/
final
class FontReaderFactory {
private:
@nogc:
    __gshared map!(string, FontReader) readers;
    __gshared weak_vector!string registered_;

public:

    /**
        Returns a list of named readers.
    */
    static @property string[] registered() @trusted nothrow { return registered_[]; }

    /**
        Attempts to create a font reader for the given stream.

        Note:
            This method requires that the stream in question can
            be seeked and read. The stream additionally must have
            a length.
        
        Threadsafety:
            This can safely be called from any thread.
    */
    static FontReader tryCreateFor(Stream stream) @trusted {
        if (!stream.canRead()) throw nogc_new!StreamReadException(stream, "Stream is not readable!");
        if (!stream.canSeek()) throw nogc_new!StreamReadException(stream, "Stream is not seekable!");

        foreach(FontReader reader; readers.byValue) {
            
            stream.seek(0);
            if (auto newReader = reader.tryCreateReader(stream))
                return newReader;
        }

        stream.seek(0);
        return null;
    }

    /**
        Tries to create a font reader for the given name.

        Note:
            This method requires that the stream in question can
            be seeked and read. The stream additionally must have
            a length.
        
        Threadsafety:
            This can safely be called from any thread.
    */
    static FontReader tryCreateFor(string name, Stream stream) @trusted {
        return name in readers ? readers[name].tryCreateReader(stream) : null;
    }

    /**
        Registers a font reader in the factory.
        
        Threadsafety:
            This should only be called by the main thread 
            on app startup.
    */
    static bool register(T)(string name) @system {
        import numem.core.traits : AllocSize;
        import numem.core.hooks : nu_malloc;

        // Name collision not allowed.
        if (name in readers)
            return false;

        // Type collission not allowed.
        foreach(reader; readers) {
            if (cast(T)reader) 
                return false;
        }

        // Allocate and base-initialize an instance of the class.
        void[] entity = nu_malloc(AllocSize!T)[0..AllocSize!T];
        nogc_initialize!T(entity);
        readers[name] = cast(T)entity.ptr;
        return true;
    }

    /**
        Clears the registered readers.
        
        Threadsafety:
            This should only be called by the main thread 
            on app shutdown.
    */
    static void clear() @system {
        nogc_delete(readers);
        nogc_delete(registered_);
    }
}

/**
    A reader for a font
*/
abstract
class FontReader : NuObject {
private:
@nogc:
    StreamReader reader;
    Stream stream;

    size_t getStreamLength(Stream stream) {
        stream.seek(0, SeekOrigin.end);
        size_t rlen = cast(size_t)stream.tell();
        stream.seek(0);
        return rlen;
    }

    MemoryStream readAllToMemoryStream(Stream stream, size_t offset, size_t length) {
        ubyte[] buffer;
        buffer = buffer.nu_resize(length);

        // Read data into buffer
        stream.seek(offset);
        stream.read(buffer);
        stream.seek(0);
        return nogc_new!MemoryStream(buffer);
    }

protected:
    
    /**
        Called by the internal font factory to query whether the stream
        can be read.
    */
    abstract FontReader tryCreateReader(Stream stream) @system nothrow;

public:

    /*
        Destructor
    */
    ~this() @trusted {
        this.close();
    }
    /**
        Constructs a new SFNT Reader from a stream.

        Params:
            stream =    the stream to read from, the reader takes
                        ownership of the stream given.

        Note:
            Flushable streams will be read fully and copied to a new
            MemoryStream, the SFNTFontReader becomes the owner of
            the input stream.
    */
    this(Stream stream) @trusted {
        if (!stream.canRead()) nogc_new!StreamReadException(stream, "Stream is not readable!");
        if (!stream.canSeek()) nogc_new!StreamReadException(stream, "Stream is not seekable!");

        // NOTE:    Streams that can be flushed, eg. file streams might end up
        //          blocking file access, which would be bad for fonts.
        //          so to prevent file locking, we read the entire font into
        //          memory.
        if (stream.canFlush()) {
            stream = this.readAllToMemoryStream(stream, 0u, getStreamLength(stream));
        }

        this.stream = stream;
        this.reader = nogc_new!StreamReader(stream);
    }

    /**
        Reads a single element from the stream
    */
    T readElementBE(T)() @trusted {
        static if (is(typeof((T rt) { rt.deserialize(FontReader.init); })))
            return T.init.deserialize(reader);
        else static if (__traits(isScalar, T))
            return reader.readBE!T;
        else static if (__traits(isUnsigned, T))
            return reader.readBE!T;
        else static if(isFixed!T)
            return T.fromData(reader.readBE!(typeof(T.data)));
        else static if (__traits(isStaticArray, T)) {
            T tmp;
            foreach(i; 0..tmp.length) {
                tmp[i] = this.readElementBE!(typeof(tmp[0]))();
            }
            return tmp;
        } else static assert(0, "Type " ~ T.stringof ~ " not supported.");
    }

    /**
        Reads a single element from the stream
    */
    T readElementLE(T)() @trusted {
        static if (is(typeof((T rt) { rt.deserialize(FontReader.init); })))
            return T.init.deserialize(reader);
        else static if (__traits(isScalar, T))
            return reader.readLE!T;
        else static if (__traits(isUnsigned, T))
            return reader.readLE!T;
        else static if(isFixed!T)
            return T.fromData(reader.readLE!(typeof(T.data)));
        else static if (__traits(isStaticArray, T)) {
            T tmp;
            foreach(i; 0..tmp.length) {
                tmp[i] = this.readElementBE!(typeof(tmp[0]))();
            }
            return tmp;
        } else static assert(0, "Not supported.");
    }

    /**
        Reads a single record from the stream
    */
    T readRecordBE(T)() if (isStructLike!T) {
        T rt;

        static if (is(typeof((T rt) { rt.deserialize(FontReader.init); }))) {
            rt.deserialize(this);
        } else {
            alias members = rt.tupleof;
            alias fields = Fields!T;

            // Iterates through every member of the struct that is a scalar.
            static foreach(i, fieldT; fields) {
                {
                    static if (isStructLike!fieldT) {
                        members[i] = this.readRecordBE!fieldT;
                    } else static if (__traits(isStaticArray, fieldT)) {
                        static if (fieldT.init[0].sizeof == 1) {
                            this.read(cast(ubyte[])members[i]);
                        } else {
                            members[i] = this.readElementBE!fieldT;
                        }
                    } else {
                        members[i] = this.readElementBE!fieldT;
                    }
                }
            }
        }

        return rt;
    }

    /**
        Reads a single record from the stream
    */
    T readRecordLE(T)() if (isStructLike!T) {
        T rt;

        static if (is(typeof((T rt) { rt.deserialize(FontReader.init); }))) {
            rt.deserialize(this);
        } else {
            alias members = rt.tupleof;
            alias fields = Fields!T;

            // Iterates through every member of the struct that is a scalar.
            static foreach(i, fieldT; fields) {
                {
                    static if (isStructLike!fieldT) {
                        members[i] = this.readRecordLE!fieldT;
                    } else static if (__traits(isStaticArray, fieldT)) {
                        static if (fieldT.init[0].sizeof == 1) {
                            this.read(cast(ubyte[])members[i]);
                        } else {
                            members[i] = this.readElementLE!fieldT;
                        }
                    } else {
                        members[i] = this.readElementLE!fieldT;
                    }
                }
            }
        }

        return rt;
    }

    /**
        Reads multiple record from the stream.
    */
    void readRecordsBE(T)(T[] dst) if (is(T == struct)) {
        foreach(i; 0..dst.length) {
            dst[i] = this.readRecordBE!T();
        }
    }

    /**
        Reads multiple record from the stream.
    */
    void readRecordsLE(T)(T[] dst) if (is(T == struct)) {
        foreach(i; 0..dst.length) {
            dst[i] = this.readRecordLE!T();
        }
    }

    /**
        Reads a range of elements and stores them
        in the given range slice.
    */
    void readElementsBE(T)(T[] range) @trusted {
        foreach(i; 0..range.length) {
            range[i] = this.readElementBE!T();
        }
    }

    /**
        Reads a range of elements and stores them
        in the given range slice.
    */
    void readElementsLE(T)(T[] range) @trusted {
        foreach(i; 0..range.length) {
            range[i] = this.readElementLE!T();
        }
    }

    /**
        Peeks the value of a byte at the given index.

        Params:
            offset = The offset to peek at.

        Returns:
            The byte at the given offset.
    */
    final
    ubyte peek(size_t offset = 0) {

        stream.seek(offset, SeekOrigin.relative);
        ubyte rval = this.read();
        stream.seek(-(cast(ptrdiff_t)offset+1), SeekOrigin.relative);
        return rval;
    }

    /**
        Reads a single byte from the stream.
    */
    final
    ubyte read() {
        ubyte[1] rval;
        stream.read(rval[0..$]);
        return rval[0];
    }

    /**
        Reads raw bytes from the underlying stream
        into the given buffer.
    */
    final
    ptrdiff_t read(ubyte[] buffer) {
        return stream.read(buffer);
    }

    /**
        Reads a UTF8 string from the stream.
    */
    final
    nstring readUTF8(size_t bytes) @trusted {
        return reader.readUTF8(cast(uint)bytes);
    }

    /**
        Reads a UTF16 string from the stream.
    */
    final
    nstring readUTF16BE(size_t bytes) @trusted {
        assert((bytes % 2) == 0, "Unaligned byte read!");
        if (bytes == 0 || (bytes % 2) != 0)
            return nstring.init;
        
        return toUTF8(reader.readUTF16BE(cast(uint)bytes/2));
    }

    /**
        Reads a UTF16 string from the stream.
    */
    final
    nstring readUTF16LE(size_t bytes) @trusted {
        if (bytes == 0 || (bytes % 2) != 0)
            return nstring.init;
        
        assert((bytes % 2) == 0, "Unaligned byte read!");
        return toUTF8(reader.readUTF16LE(cast(uint)bytes/2));
    }

    /**
        Seeks the reader to the given offset.
    */
    final
    void seek(size_t offset) @trusted {
        this.stream.seek(offset);
    }

    /**
        Gets the position in the stream
    */
    final
    long tell() @trusted {
        return this.stream.tell();
    }

    /**
        Skips the given amount of bytes of the stream.
    */
    final
    void skip(size_t bytes) @trusted {
        this.stream.seek(bytes, SeekOrigin.relative);
    }

    /**
        Closes the underlying stream in the font reader.
    */
    final
    void close() {
        this.stream.close();
        if (reader) nogc_delete(reader);
        if (stream) nogc_delete(stream);
    }

    /**
        Creates a font instance associated with the reader.
    */
    abstract FontFile createFont(string name);
}

/**
    An exception thrown by the FontFile loader.
*/
class FontReadException : NuException {
@nogc:
public:
    this(string reason, string file = __FILE__, size_t line = __LINE__) {
        super(reason, null, file, line);
    }
}

/**
    Initializes the font readers subsystem.
*/
extern(C)
bool ha_init_fonts_reader() @nogc {
    import hairetsu : haIsInitialized;
    if (haIsInitialized) 
        return true;

    import hairetsu.font.sfnt.reader : SFNTReader;
    if (!FontReaderFactory.register!SFNTReader("sfnt"))
        return false;

    return true;
}


/**
    Initializes the font readers subsystem.
*/
extern(C)
bool ha_shutdown_fonts_reader() @nogc {
    import hairetsu : haIsInitialized;
    if (!haIsInitialized) 
        return true;

    FontReaderFactory.clear();
    return true;
}
