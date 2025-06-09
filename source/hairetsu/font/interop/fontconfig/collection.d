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
    Helper that determines format support.
*/
bool isFontSupported(const(char)* fmt) {
    enum SUPPORTED_FORMATS = [ // @suppress(dscanner.performance.enum_array_literal)
        "TrueType", 
        "Type 1", 
        "CFF",
    ];

    // NOTE:    String switches requires compiler support;
    //          as such we use basic if statements instead.
    static foreach(format; SUPPORTED_FORMATS) {
        if (fmt == format)
            return true;
    }
    return false;
}

/**
    Function to enumerate the system fonts.
*/
extern(C) FontCollection _ha_fontcollection_from_system(bool update) @nogc {
    _ha_fc_fontcollection_init(update);
    FcPattern* pattern = FcPatternCreate();
    FcObjectSet* objects = FcObjectSetBuild(FC_FAMILY, FC_FULLNAME, FC_POSTSCRIPT_NAME, FC_CHARSET, FC_FONTFORMAT, FC_FILE, cast(char*)null);
    FcFontSet* fonts = FcFontList(fc, pattern, objects);

    // Allocate faces; we'll allocate for every font, even unsupported ones.
    // We will be discarding this array anyways.
    FontFaceInfo[] faces = ha_allocarr!FontFaceInfo(fonts.nfont);
    uint faceIdx;

    // Step 1. Get all the valid fonts.
    foreach(i; 0..fonts.nfont) {
        FcPattern* font = fonts.fonts[i];
        const(char)* family;

        if (FcPatternGetString(font, FC_FAMILY, 0, family) == FcResult.Match) {
            const(char)* format;
            FcPatternGetString(font, FC_FONTFORMAT, 0, format);

            // Skip unsupported fonts.
            if (!isFontSupported(format))
                continue;
            

            const(char)* file;
            const(char)* fullName;
            const(char)* psName;
            FcCharSet* charSet;
            FcPatternGetString(font, FC_FILE, 0, file);
            FcPatternGetString(font, FC_FULLNAME, 0, fullName);
            FcPatternGetString(font, FC_POSTSCRIPT_NAME, 0, psName);
            FcPatternGetCharSet(font, FC_CHARSET, 0, charSet);

            faces[faceIdx] = nogc_new!FCFontFaceInfo(charSet);
            faces[faceIdx].familyName = fullName.fromStringz().nu_dup();

            // Optional info
            if (file) faces[faceIdx].path = file.fromStringz().nu_dup();
            if (fullName) faces[faceIdx].name = fullName.fromStringz().nu_dup();
            if (psName) faces[faceIdx].postscriptName = psName.fromStringz().nu_dup();
            faces[faceIdx].sampleText = faces[faceIdx].name.nu_dup();

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
    nogc_delete(families);
    FcFontSetDestroy(fonts);
    FcObjectSetDestroy(objects);
    FcPatternDestroy(pattern);
    return collection;
}

class FCFontFaceInfo : FontFaceInfo {
private:
@nogc:
    FcCharSet* charset;

public:

    /**
        Destructor
    */
    ~this() {
        FcCharSetDestroy(charset);
    }

    /**
        Constructor
    */
    this(FcCharSet* charset) {
        this.charset = FcCharSetCopy(charset);
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
}