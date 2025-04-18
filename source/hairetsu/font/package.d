/**
    Hairetsu Font System

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font;
import hairetsu.font.reader;
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
class HaFont : NuObject {
@nogc:
private:
    nstring name_;
    weak_vector!HaFontFace faces_;

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
    abstract void onIndexFont(ref weak_vector!HaFontFace faces);

public:

    final @property string name() { return name_[]; }

    /**
        Font faces within the font.
    */
    final @property HaFontFace[] faces() { return faces_[]; }

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
            A $(D HaFont) instance on success,
            $(D null) on failure.
    */
    static HaFont createFont(Stream stream, string name = "<memory stream>") {
        if (HaFontReader reader = HaFontReaderFactory.tryCreateFor(stream)) {
            return reader.createFont(name);
        }
        return null;
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
    A Font Object
*/
abstract
class HaFontFace : NuRefCounted {
@nogc:
private:
    uint index_;

protected:
    
    /**
        Implemented by the font face to read the face.
    */
    abstract void onFaceLoad(HaFontReader reader);
    
public:

    /**
        Index of face within font file.
    */
    final @property size_t index() { return index_; }

    /**
        Constructs a new font face from a stream.
    */
    this(uint index, HaFontReader reader) {
        this.index_ = index;
        this.onFaceLoad(reader);
    }

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
        The name of the type of font.
    */
    abstract @property string type();

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

/**
    An exception thrown by the FontFile loader.
*/
class HaFontReadException : NuException {
@nogc:
public:
    this(string reason, string file = __FILE__, size_t line = __LINE__) {
        super(reason, null, file, line);
    }
}


/**
    Initializes the font loader subsystem.
*/
extern(C)
bool ha_init_fonts() @nogc {
    import hairetsu : ha_get_initialized;
    if (ha_get_initialized) 
        return true;

    import hairetsu.font.reader : ha_init_fonts_reader;
    if (!ha_init_fonts_reader())
        return false;
    
    return true;
}

/**
    Initializes the font loader subsystem.
*/
extern(C)
bool ha_shutdown_fonts()  @nogc {
    import hairetsu : ha_get_initialized;
    if (!ha_get_initialized) 
        return true;

    import hairetsu.font.reader : ha_shutdown_fonts_reader;
    if (!ha_shutdown_fonts_reader())
        return false;
    
    return true;
}
