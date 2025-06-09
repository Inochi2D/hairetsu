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
private 
extern(C) FontCollection _ha_fontcollection_from_system(bool update) @weak @nogc {
    return null;
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
class FontFamily : FontCollection {
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
        Whether the font is a valid instance.
    */
    final
    @property bool isValidFont() {
        return path.length > 0 || stream;
    }

    /**
        Gets whether the font has the specified character.
    */
    abstract bool hasCharacter(codepoint character);

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
