/**
    Hairetsu Font Collections for FontConfig

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.fontconfig.collection;
import hairetsu.font.interop.fontconfig.fontconfig;
import hairetsu.font.collection;
import hairetsu.font.glyph;
import hairetsu.font.font;
import hairetsu.font.file;
import hairetsu.common;
import nulib.collections.map;
import numem;

version(HA_FONTCONFIG):

__gshared FcConfig* fc;
void _ha_fc_fontcollection_init(bool update) @nogc {
    if (!fc)
        fc = FcInitLoadConfigAndFonts();

    FcInitBringUptoDate();
}

/**
    Function to enumerate the system fonts.
*/
extern(C) FontCollection _ha_fontcollection_from_system(bool update) @nogc {
    _ha_fc_fontcollection_init(update);
    FcPattern* pattern = FcPatternCreate();
    FcObjectSet* objects = FcObjectSetBuild(FC_FAMILY, FC_FULLNAME, FC_POSTSCRIPT_NAME, FC_CHARSET, FC_INDEX, FC_FILE, cast(char*)null);
    FcFontSet* fonts = FcFontList(fc, pattern, objects);

    // Allocate faces; we'll allocate for every font, even unsupported ones.
    // We will be discarding this array anyways.
    FontFaceInfo[] faces = ha_allocarr!FontFaceInfo(fonts.nfont);
    uint faceIdx;

    import std.stdio : printf;

    // Step 1. Get all the valid fonts.
    foreach(i; 0..fonts.nfont) {
        FcPattern* font = fonts.fonts[i];
        const(char)* family;

        if (FcPatternGetString(font, FC_FAMILY, 0, family) == FcResult.Match) {
            const(char)* file;
            const(char)* fullName;
            const(char)* psName;
            const(char)* format;
            FcCharSet* charSet;
            int index;

            FcPatternGetString(font, FC_FILE, 0, file);
            FcPatternGetString(font, FC_FULLNAME, 0, fullName);
            FcPatternGetString(font, FC_POSTSCRIPT_NAME, 0, psName);
            FcPatternGetString(font, FC_FONTFORMAT, 0, format);
            FcPatternGetCharSet(font, FC_CHARSET, 0, charSet);
            FcPatternGetInteger(font, FC_INDEX, 0, index);

            // Skip unnamed.
            if (!fullName)
                continue;
            
            if (!file)
                continue;

            faces[faceIdx] = nogc_new!FCFontFaceInfo(charSet, index);
            faces[faceIdx].familyName = cast(string)family.fromStringz().nu_dup();

            // Optional info
            if (format) faces[faceIdx].outlines = format.fromStringz().toGlyphType();
            if (file) faces[faceIdx].path = cast(string)file.fromStringz().nu_dup();
            if (fullName) faces[faceIdx].name = cast(string)fullName.fromStringz().nu_dup();
            if (psName) faces[faceIdx].postscriptName = cast(string)psName.fromStringz().nu_dup();
            faces[faceIdx].sampleText = cast(string)faces[faceIdx].name.nu_dup();
            
            FcPatternGetBool(font, FC_VARIABLE, 0, faces[faceIdx].variable);

            // Retain the face so that later deletion of our temp array doesn't
            // free it.
            faces[faceIdx].retain();
            faceIdx++;
        }

    }

    // Step 2. Convert to collection.
    faces = faces[0..faceIdx];
    FontCollection collection = faces.collectionFromFaces();

    // Step 3. Final cleanup.
    ha_freearr(faces);
    FcFontSetDestroy(fonts);
    FcObjectSetDestroy(objects);
    FcPatternDestroy(pattern);
    return collection;
}

class FCFontFaceInfo : FontFaceInfo {
private:
@nogc:
    FcCharSet* charset;
    int index;

public:

    /**
        Destructor
    */
    ~this() {
        FcCharSetDestroy(charset);
        charset = null;
    }

    /**
        Constructor
    */
    this(FcCharSet* charset, int index) {
        this.charset = FcCharSetCopy(charset);
        this.index = index;
    }

    /**
        Gets whether the font has the specified character.

        Params:
            code = The unicode codepoint to query for.
        
        Returns:
            $(D true) if the face has the given unicode code point,
            $(D false) otherwise.
    */
    override
    bool hasCharacter(codepoint code) {
        return FcCharSetHasChar(charset, code);
    }

    /**
        Realises the font face into a Hairetsu font object.

        Returns:
            The font created from the font info.
    */
    override
    Font realize() {
        if (!path)
            return null;

        return this.realizeFromFile(FontFile.fromFile(path), index);
    }
}