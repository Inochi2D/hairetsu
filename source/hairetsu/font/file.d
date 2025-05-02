/**
    Hairetsu Font File Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.file;
import hairetsu.font.reader;
import hairetsu.font.font;
import nulib.text.unicode;
import nulib.collections;
import nulib.io.stream;
import nulib.string;
import numem;
import nulib.io.stream.file;

/**
    A font file
*/
abstract
class HaFontFile : NuRefCounted {
@nogc:
private:
    nstring name_;
    weak_vector!HaFont faces_;

    // Clears and removes a refcount from all faces.
    void clearFaces() {
        if (!faces_.empty) {
            foreach(ref element; faces_[])
                element.release();
            
            faces_.resize(0);
        }
    }

protected:

    /**
        The backing font reader
    */
    HaFontReader reader;
    
    /**
        Implemented by the font file reader to index the faces.
    */
    abstract void onIndexFont(ref weak_vector!HaFont faces);

public:

    /**
        The name of the file, usually its file path.
    */
    final @property string name() { return name_[]; }

    /**
        Font Objects within the file
    */
    final @property HaFont[] fonts() { return faces_[]; }

    /**
        The type of the font file, essentially its container.
    */
    abstract @property string type();

    /*
        Destructor
    */
    ~this() {
        this.clearFaces();

        // Delete old reader
        if (this.reader) {
            nogc_delete(this.reader);
        }
    }

    /**
        Constructs a font file from a stream.

        Params:
            reader =    The font reader to read the file from.
            name =      (optional) name of the font, usually its file path
    */
    this(HaFontReader reader, string name) {
        this.name_ = name;
        this.reader = reader;
        this.onIndexFont(faces_);
    }
    
    /**
        Creates a new font for the given stream.

        Params:
            stream =    The stream to create a font from
            name =      The name to give the font.
        
        Returns:
            A $(D HaFontFile) instance on success,
            $(D null) on failure.
    */
    static HaFontFile fromStream(Stream stream, string name = "<memory stream>") {
        if (HaFontReader reader = HaFontReaderFactory.tryCreateFor(stream)) {
            return reader.createFont(name);
        }
        return null;
    }

    /**
        Creates a new font for the given memory slice

        Params:
            data =  The memory slice to read the font data from.
            name =  The name to give the font.
        
        Returns:
            A $(D HaFontFile) instance on success,
            $(D null) on failure.
        
        Note:
            This function will copy the memory out of data,
            this is to ensure ownership of the data is properly handled.
    */
    static HaFontFile fromMemory(ubyte[] data, string name = "<memory stream>") {
        auto stream = nogc_new!MemoryStream(data.nu_dup);
        if (HaFontFile file = HaFontFile.fromStream(stream, name))
            return file;

        nogc_delete(stream);
        return null;
    }

    /**
        Creates a new font for the given file path

        Params:
            path =  Path to the file containing the font.
        
        Returns:
            A $(D HaFontFile) instance on success,
            $(D null) on failure.
    */
    static HaFontFile fromFile(string path) {
        auto stream = nogc_new!FileStream(path, "rb");
        if (HaFontFile file = HaFontFile.fromStream(stream, path))
            return file;

        nogc_delete(stream);
        return null;
    }
}