/**
    Hairetsu Font Collections

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.collection;
import hairetsu.font.font;
import hairetsu.font.file;
import hairetsu.font.glyph;
import hairetsu.common;
import nulib.io.stream;
import core.attribute;
import numem;

// Implemented by the backend.
private {
    version(HA_GENERIC) {
        extern(C) FontCollection _ha_fontcollection_from_system(bool update) @weak @nogc {
            return nogc_new!FontCollection();
        }
    } else {

        // NOTE: DMD does not support weak symbols like LDC and GDC,
        //       so this ugly hack lies here.
        //       Given that we already define HA_GENERIC when we don't have
        //       A specific backend, this *should* be fine.
        extern(C) FontCollection _ha_fontcollection_from_system(bool update) @weak @nogc;
    }
}

/**
    A collection of fonts.
*/
class FontCollection : NuRefCounted {
private:
@nogc:
    FontFamily[] _families;

public:

    /**
        Destructor
    */
    ~this() {
        nu_freea(_families);
    }

    /**
        Creates a font collection from the system.
    */
    static FontCollection createFromSystem(bool update = false) {
        return _ha_fontcollection_from_system(update);
    }

    /**
        The font families within the collection
    */
    final
    @property FontFamily[] families() {
        return _families;
    }

    /**
        Adds a font to the collection.
    */
    final
    void addFamily(FontFamily family) {
        this._families = _families.nu_resize(_families.length+1);
        this._families[$-1] = family;
    }
}

/**
    A font family used during font enumeration.
*/
class FontFamily : NuRefCounted {
private:
@nogc:
    FontFaceInfo[] faces_;
    nstring familyName_;

public:

    /**
        Destructor
    */
    ~this() {
        familyName_.clear();
        nu_freea(faces_);
    }

    /**
        Creates a new font family.
    */
    this() { }

    /**
        Name of the font family.
    */
    @property string familyName() => familyName_[];
    @property void familyName(string value) { familyName_ = value; }

    /**
        The fonts within the collection
    */
    final
    @property FontFaceInfo[] faces() {
        return faces_;
    }

    /**
        Gets whether any font within the family has the specified 
        character.

        Params:
            code = The unicode codepoint to query for.
        
        Returns:
            $(D true) if the family has a face with the given 
            unicode code point, $(D false) otherwise.
    */
    final
    bool hasCharacter(codepoint code) {
        foreach(face; faces_) {
            if (face.hasCharacter(code))
                return true;
        }

        return false;
    }

    /**
        Gets the first font face in the family with the given
        character.

        Params:
            code = The unicode codepoint to query for.
        
        Returns:
            The first $(D FontFaceInfo) that supports said codepoint,
            otherwise $(D null) if none was found.
    */
    final
    FontFaceInfo getFirstFaceWith(codepoint code) {
        foreach(face; faces_) {
            if (face.hasCharacter(code)) {
                return face;
            }
        }
        return null;
    }

    /**
        Adds a font to the collection.
    */
    final
    void addFace(FontFaceInfo font) {
        this.faces_ = faces_.nu_resize(faces_.length+1);
        this.faces_[$-1] = font;
    }
}

/**
    A virtual font, in other words one that isn't by itself
    usable; a $(D Font) object must be created from it. 
*/
abstract
class FontFaceInfo : NuRefCounted {
private:
@nogc:
    Stream stream;
    nstring path_;
    nstring name_;
    nstring postscriptName_;
    nstring familyName_;
    nstring subfamilyName_;
    nstring sampleText_;

protected:

    /**
        Helper implementation which provides a simple "realize"
        implementation for an already open font file.
        
        Note:
            The font file will be released after this operation.

        Params:
            fFile = The font file to realize.
            index = The index within the file to realize.

        Returns:
            A new font object from the font file.
    */
    final
    Font realizeFromFile(FontFile fFile, uint index) {
        Font font;
        
        if (fFile.fonts.length > 0) {
            
            // Fallback if we somehow got a malformed index.
            if (index >= fFile.fonts.length)
                index = 0;

            // Font found, retain it while releasing the
            // font file; this should allow continued used
            // of the fetched font object.
            font = fFile.fonts[0];
            font.retain();
        }
        fFile.release();
        return font;
    }

public:

    /**
        Destructor
    */
    ~this() {
        path_.clear();
        name_.clear();
        postscriptName_.clear();
        familyName_.clear();
        subfamilyName_.clear();
        sampleText_.clear();
        if (stream) nogc_delete(stream);
    }

    this() { }

    /**
        Creates a font from a path.

        Params:
            path = The path to the file to create the font from.
    */
    void setData(string path) {
        this.path = path.nu_dup();
    }

    /**
        Creates a font from a memory buffer.

        Params:
            data = The data to create the font from.
    */
    void setData(ubyte[] data) {
        this.stream = nogc_new!MemoryStream(data);
    }

    /**
        Creates a font from a stream.

        Params:
            stream = The stream to create the font from.
    */
    void setData(Stream stream) {
        this.stream = stream;
    }

    /**
        Path to the font.
    */
    @property string path() => path_[];
    @property void path(string value) { path_ = value; }

    /**
        Name of the font.
    */
    @property string name() => name_[];
    @property void name(string value) { name_ = value; }

    /**
        Postscript name of the font.
    */
    @property string postscriptName() => postscriptName_[];
    @property void postscriptName(string value) { postscriptName_ = value; }

    /**
        The name of the font family the font belongs to.
    */
    @property string familyName() => familyName_[];
    @property void familyName(string value) { familyName_ = value; }

    /**
        The name of the font sub-family the font belongs to.
    */
    @property string subfamilyName() => subfamilyName_[];
    @property void subfamilyName(string value) { subfamilyName_ = value; }

    /**
        The sample text to show for a given font.
    */
    @property string sampleText() => sampleText_[];
    @property void sampleText(string value) { sampleText_ = value; }

    /**
        The kind of outlines stored in the file.
    */
    GlyphType outlines;

    /**
        Whether the font is variable.
    */
    bool variable;

    /**
        Whether the face is a valid instance.
    */
    final
    @property bool isRealizable() {
        return path.length > 0 || stream;
    }

    /**
        Gets whether the font has the specified character.

        Params:
            code = The unicode codepoint to query for.
        
        Returns:
            $(D true) if the face has the given unicode code point,
            $(D false) otherwise.
    */
    abstract bool hasCharacter(codepoint code);

    /**
        Realises the font face into a Hairetsu font object.

        Returns:
            A font created from the font info.
    */
    Font realize() {

        // Open the font file.
        FontFile fFile;
        if (stream)
            fFile = FontFile.fromStream(stream, name);
        else if (path)
            fFile = FontFile.fromFile(path);

        return this.realizeFromFile(fFile, 0);
    }
}

/**
    Creates a font collection from a series of faces, organized by
    family.

    Params:
        faces = The faces to turn into a collection.

    Returns:
        A newly populated FontCollection.
*/
FontCollection collectionFromFaces(FontFaceInfo[] faces) @nogc {
    FontCollection collection = nogc_new!FontCollection();
    import nulib.collections.map : weak_map;

    weak_map!(string, FontFamily) families;
    foreach(i; 0..faces.length) {
        string fname = faces[i].familyName;
        if (fname !in families) {
            families[fname] = nogc_new!FontFamily();

            // Copy family name since the family also deletes its own name ref.
            families[fname].familyName = faces[i].familyName.nu_dup();
        }

        families[fname].addFace(faces[i]);
    }

    // Step 3. Add them to the collection.
    foreach(family; families.byValue) {
        collection.addFamily(family);
    }
    return collection;
}

@("FontCollection")
unittest {
    FontCollection fc = FontCollection.createFromSystem();
    assert(fc.families.length > 0);

    foreach(FontFamily family; fc.families) {
        assert(family.faces.length > 0);
    }
}