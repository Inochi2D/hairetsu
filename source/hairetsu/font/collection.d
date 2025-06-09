/**
    Hairetsu Font Collections

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.collection;
import core.attribute;
import hairetsu.font.font;
import hairetsu.font.file;
import hairetsu.common;
import nulib.io.stream;
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
        ha_freearr(_families);
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
    FontFaceInfo[] _faces;

public:

    /**
        Destructor
    */
    ~this() {
        ha_freearr(familyName);
        ha_freearr(_faces);
    }

    /**
        Creates a new font family.
    */
    this() { }

    /**
        Name of the font family.
    */
    string familyName;

    /**
        The fonts within the collection
    */
    final
    @property FontFaceInfo[] faces() {
        return _faces;
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
        foreach(face; faces) {
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
        foreach(face; faces) {
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
        this._faces = _faces.nu_resize(_faces.length+1);
        this._faces[$-1] = font;
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

public:

    /**
        Destructor
    */
    ~this() {
        ha_freearr(path);
        ha_freearr(name);
        ha_freearr(postscriptName);
        ha_freearr(familyName);
        ha_freearr(subfamilyName);
        ha_freearr(sampleText);
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
    string path;

    /**
        Name of the font.
    */
    string name;

    /**
        Postscript name of the font.
    */
    string postscriptName;

    /**
        The name of the font family the font belongs to.
    */
    string familyName;

    /**
        The name of the font sub-family the font belongs to.
    */
    string subfamilyName;

    /**
        The sample text to show for a given font.
    */
    string sampleText;

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
        Realises the virtual font.

        Returns:
            The font created from the font info.
    */
    FontFile realize() {
        if (stream)
            return FontFile.fromStream(stream, name);
        
        if (path)
            return FontFile.fromFile(path);
        
        return null;
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