/**
    Hairetsu SFNT Reader

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.reader;
public import hairetsu.font.sfnt.types;
public import hairetsu.font.reader;
import hairetsu.common;
import hairetsu.font;

import nulib.collections;
import nulib.io.stream.rw;
import nulib.io.stream;
import numem.core.traits : Fields, isStructLike;
import numem;

/**
    A class which handles reading tables and records from a SFNT formatted
    file, such as TrueType or OpenType fonts.
*/
class SFNTReader : HaFontReader {
private:
@nogc:
    vector!SFNTFontEntry fonts_;
    vector!SFNTTableRecord tables_;

    SFNTFontEntry parseSFNTEntry(uint tag, uint idx, uint offset) {
        SFNTFontEntry entry;

        // Determine tag
        switch(tag) {

            // OpenType
            case ISO15924!("OTTO"):
            case 0x00010000:
                entry.type = SNFTFontType.openType;
                break;
            
            // TrueType
            case ISO15924!("true"):
                entry.type = SNFTFontType.trueType;
                break;
            
            // Type 1
            case ISO15924!("typ1"):
                entry.type = SNFTFontType.postScript;
                break;
            
            // TrueType Collections
            case ISO15924!("ttcf"):
                throw nogc_new!HaFontReadException("Nested collections are not supported!");

            default:
                throw nogc_new!HaFontReadException("Unsupported font format ID!");
        }

        // Parse rest of header.
        uint tableBegin = cast(uint)tables_.length;
        entry.index = idx;
        entry.offset = offset;
        entry.header = this.readRecord!SFNTHeader;
        foreach(table; 0..entry.header.tableCount)
            tables_ ~= this.readRecord!SFNTTableRecord;
        entry.tables = tables_[tableBegin..$];
        return entry;
    }

    void parseHeader(uint idx = 0, uint offset = 0) {
        size_t rptr = this.tell();

        // Get tag, then realign.
        uint fileTag = this.readElementBE!uint();
        this.seek(rptr);

        switch(fileTag) {
            
            // TrueType Collections
            case ISO15924!("ttcf"):

                // Read important info
                this.skip(4);
                uint faceCount = this.readElementBE!uint();
                foreach(i; 0..faceCount) {
                    uint foffset = this.readElementBE!uint();
                    size_t rptr2 = this.tell();
                    
                    this.seek(offset);
                    this.parseHeader(i, foffset);
                    this.seek(rptr2);
                }
                break;
            
            default:
                this.fonts_ ~= this.parseSFNTEntry(fileTag, idx, offset);
                break;
        }
    
        this.seek(rptr);
    }

protected:
    
    /**
        Called by the internal font factory to query whether the stream
        can be read.
    */
    override
    HaFontReader tryCreateReader(Stream stream) @system nothrow {
        try {
            return nogc_new!SFNTReader(stream);
        } catch(Exception ex) {

            if (ex !is null) {
                try {
                    nogc_delete(ex);
                } catch(Exception ex) {
                    assert(0, "Failed deleting exception!");

                    // At this point this might just go on forever,
                    // so, we'll leak.
                    return null;
                }
            }
            return null;
        }
    }

public:

    /**
        The font entries of the font.

        Note:
            The entries are just the individual subfonts of a font,
            this does *not* include font variations.
    */
    @property SFNTFontEntry[] fontEntries() { return fonts_[]; }

    /*
        Destructor
    */
    ~this() {
        if (fonts_) nogc_delete(fonts_);
        if (tables_) nogc_delete(tables_);
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
    this(Stream stream) {
        super(stream);
        this.parseHeader();
    }

    /**
        Reads a single record from the stream
    */
    T readRecord(T)() if (isStructLike!T) {
        T rt;

        static if (is(typeof((T rt) { rt.deserialize(SFNTReader.init); }))) {
            rt.deserialize(this);
        } else {
            alias members = rt.tupleof;
            alias fields = Fields!T;

            // Iterates through every member of the struct that is a scalar.
            static foreach(i, fieldT; fields) {
                {
                    static if (isStructLike!fieldT) {
                        members[i] = this.readRecord!fieldT;
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
        Reads multiple record from the stream.
    */
    vector!T readRecords(T)(uint count) if (is(T == struct)) {
        vector!T records;
        foreach(i; 0..count) {
            records ~= this.readRecord!T();
        }
        return records;
    }

    /**
        Creates a font instance using this reader.
    */
    override
    HaFontFile createFont(string name) {
        import hairetsu.font.sfnt.file : SFNTFontFile;
        return nogc_new!SFNTFontFile(this, name);
    }
}

/**
    Font entries for a SFNT.

    For non-collection fonts there will be just a single
    entry.

    Note:
        The entry itself does not own the memory of the
        table slice, do NOT manipulate it.
*/
struct SFNTFontEntry {
@nogc:

    /**
        Index of the entry.
    */
    uint index;

    /**
        Offset into the file this table begins.
    */
    size_t offset;
    
    /**
        The type of the font
    */
    SNFTFontType type;
    
    /**
        The header of the font
    */
    SFNTHeader header;
    
    /**
        The table records of the font
    */
    SFNTTableRecord[] tables;

    /**
        Attempts to find the requested table within the font
        entry.

        Params:
            tag = The tag to look for
        
        Returns:
            A $(D SFNTTableRecord) pointer if successful,
            $(D null) otherwise.
    */
    SFNTTableRecord* findTable(uint tag) @trusted nothrow {
        foreach(ref SFNTTableRecord table; tables) {
            if (table.tag == tag)
                return &table;
        }
        
        return null;
    }
}
