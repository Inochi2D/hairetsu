/**
    Hairetsu Font System

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font;
import nulib.io.stream.rw;
import nulib.io.stream;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

/**
    A unicode character range.
*/
struct HaCharRange {
@nogc:
    
    /**
        Starting codepoint of the range.
    */
    codepoint start;
    
    /**
        Ending codepoint of the range.
    */
    codepoint end;
}

enum HaFontStyle : uint {
    normal,
    italic,
    oblique
}

/**
    Text Baseline
*/
enum HaTextBaseline : uint {
    top,
    hanging,
    middle,
    alphabetic,
    bottom
}

struct HaMetrics {
    
    /**
        The horizontal advance, in glyph units.
    */
    float hAdvance;
    
    /**
        The vertical advance, in glyph units.
    */
    float vAdvance;
    
    /**
        The leftmost extent, in glyph units.
    */
    float xMinExtent;
    
    
    /**
        The rightmost extent, in glyph units.
    */
    float xMaxExtent;
    
    /**
        The topmost extent, in glyph units.
    */
    float yMinExtent;
    
    
    /**
        The bottommost extent, in glyph units.
    */
    float yMaxExtent;
}

/**
    A font file
*/
abstract
class HaFontFile : NuObject {
@nogc:
private:
    Stream stream;
    StreamReader reader;
    weak_vector!HaFontFace faces_;

    // Clears and removes a refcount from all faces.
    void clearFaces() {
        if (!faces_.empty) {
            foreach(ref element; faces_[])
                element.release();
            
            faces_.resize(0);
        }
    }

    void reset() {
        if (reader) nogc_delete(reader);
        if (stream) nogc_delete(stream);
        this.clearFaces();

        reader = null;
        stream = null;
    }

protected:
    
    /**
        Implemented by the font file reader to index the faces.
    */
    abstract void onIndexFontFile(StreamReader reader, ref weak_vector!HaFontFace faces);

public:

    /**
        Font faces within the font.
    */
    final @property HaFontFace[] faces() { return faces_[]; }

    /*
        Destructor
    */
    ~this() {
        this.reset();
    }

    /**
        Constructs a font file from a stream.

        Params:
            stream = The stream to read the file from.
    */
    this(Stream stream) {
        this.reload(stream);
    }
    
    /**
        Reloads the font from the stream, this will reduce the refcount
        of any faces that were prior owned by the font file.
    */
    final
    void reload(Stream stream) {
        this.reset();

        // Prepare stream
        this.stream = stream;
        this.reader = nogc_new!StreamReader(stream);
        this.stream.seek(0);
        
        // Index file
        this.onIndexFontFile(reader, faces_);
    }

    /**
        Reduces the refcount of all the faces in the font file,
        this will unload all the font faces that haven't explicitly
        been taken from the file.
    */
    final
    void releaseUnused() {
        this.clearFaces();
    }

    /**
        Takes a face from the file and increases the 
        reference count of the face.
    */
    final
    HaFontFace take(uint index) {
        assert(index < faces_.length);

        return faces_[index].retained;
    }
}

/**
    An exception thrown by the FontFile loader.
*/
class HaFontFileLoadException : NuException {
@nogc:
public:
    this(string reason, string file = __FILE__, size_t line = __LINE__) {
        super(reason, null, file, line);
    }
}

/**
    A Font Object
*/
abstract
class HaFontFace : NuRefCounted {
@nogc:
private:
    uint index_;
    Stream stream;

    void reset() {
        if (reader) nogc_delete(reader);
        if (stream) nogc_delete(stream);

        reader = null;
        stream = null;
    }

protected:

    /**
        The reader for the font
    */
    StreamReader reader;
    
    /**
        Implemented by the font face to read the face.
    */
    abstract void onFaceLoad(StreamReader reader);
    
public:

    /**
        Index of face within font file.
    */
    final @property size_t index() { return index_; }

    /**
        Constructs a new font face from a stream.
    */
    this(uint index, Stream stream) {
        this.index_ = index;
        this.stream = stream;
        this.reader = nogc_new!StreamReader(stream);

        reader.stream.seek(0);
        this.onFaceLoad(reader);
    }

    /*
        Destructor
    */
    ~this() { this.reset(); }

    /**
        The postscript name of the font face.
    */
    abstract @property string name();

    /**
        The font family of the font face.
    */
    abstract @property string family();

    /**
        The sub font family of the font face.
    */
    abstract @property string subfamily();

    /**
        Amount of glyphs within font face.
    */
    abstract @property size_t glyphCount();

    /**
        Units per EM.
    */
    abstract @property uint upem();

    /**
        Fills all of the unicode codepoints that the face supports,
        and writes them to the given set.

        Params:
            cSet = The set to fill.

        Returns:
            The amount of codepoints that were added to the set.
    */
    abstract uint fillCodepoints(ref set!codepoint cSet);
}