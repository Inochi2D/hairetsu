/**
    Hairetsu Font Collections for FontConfig

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.fontconfig.fontconfig;
import hairetsu.font.glyph;
import hairetsu.common;
import nulib.string;
import numem;

version(HA_FONTCONFIG):

enum const(char)* FC_FAMILY             = "family";         /* String */
enum const(char)* FC_STYLE              = "style";          /* String */
enum const(char)* FC_SLANT              = "slant";          /* Int */
enum const(char)* FC_WEIGHT             = "weight";         /* Int */
enum const(char)* FC_SIZE               = "size";           /* Range (double) */
enum const(char)* FC_ASPECT             = "aspect";         /* Double */
enum const(char)* FC_PIXEL_SIZE         = "pixelsize";      /* Double */
enum const(char)* FC_SPACING            = "spacing";        /* Int */
enum const(char)* FC_FOUNDRY            = "foundry";        /* String */
enum const(char)* FC_ANTIALIAS          = "antialias";      /* Bool (depends) */
enum const(char)* FC_HINTING            = "hinting";        /* Bool (true) */
enum const(char)* FC_HINT_STYLE         = "hintstyle";      /* Int */
enum const(char)* FC_VERTICAL_LAYOUT    = "verticallayout"; /* Bool (false) */
enum const(char)* FC_AUTOHINT           = "autohint";       /* Bool (false) */
enum const(char)* FC_WIDTH              = "width";          /* Int */
enum const(char)* FC_FILE               = "file";           /* String */
enum const(char)* FC_INDEX              = "index";          /* Int */
enum const(char)* FC_FT_FACE            = "ftface";         /* FT_Face */
enum const(char)* FC_RASTERIZER         = "rasterizer";     /* String (deprecated) */
enum const(char)* FC_OUTLINE            = "outline";        /* Bool */
enum const(char)* FC_SCALABLE           = "scalable";       /* Bool */
enum const(char)* FC_COLOR              = "color";          /* Bool */
enum const(char)* FC_VARIABLE           = "variable";       /* Bool */
enum const(char)* FC_SCALE              = "scale";          /* double (deprecated) */
enum const(char)* FC_SYMBOL             = "symbol";         /* Bool */
enum const(char)* FC_DPI                = "dpi";            /* double */
enum const(char)* FC_RGBA               = "rgba";           /* Int */
enum const(char)* FC_MINSPACE           = "minspace";       /* Bool use minimum line spacing */
enum const(char)* FC_CHARSET            = "charset";        /* CharSet */
enum const(char)* FC_LANG               = "lang";           /* LangSet Set of RFC 3066 langs */
enum const(char)* FC_FONTVERSION        = "fontversion";    /* Int from 'head' table */
enum const(char)* FC_FULLNAME           = "fullname";       /* String */
enum const(char)* FC_FAMILYLANG         = "familylang";     /* String RFC 3066 langs */
enum const(char)* FC_STYLELANG          = "stylelang";      /* String RFC 3066 langs */
enum const(char)* FC_FULLNAMELANG       = "fullnamelang";   /* String RFC 3066 langs */
enum const(char)* FC_CAPABILITY         = "capability";     /* String */
enum const(char)* FC_FONTFORMAT         = "fontformat";     /* String */
enum const(char)* FC_EMBOLDEN           = "embolden";       /* Bool - true if emboldening needed*/
enum const(char)* FC_EMBEDDED_BITMAP    = "embeddedbitmap"; /* Bool - true to enable embedded bitmaps */
enum const(char)* FC_DECORATIVE         = "decorative";     /* Bool - true if style is a decorative variant */
enum const(char)* FC_LCD_FILTER         = "lcdfilter";      /* Int */
enum const(char)* FC_FONT_FEATURES      = "fontfeatures";   /* String */
enum const(char)* FC_FONT_VARIATIONS    = "fontvariations"; /* String */
enum const(char)* FC_NAMELANG           = "namelang";       /* String RFC 3866 langs */
enum const(char)* FC_PRGNAME            = "prgname";        /* String */
enum const(char)* FC_HASH               = "hash";           /* String (deprecated) */
enum const(char)* FC_POSTSCRIPT_NAME    = "postscriptname"; /* String */
enum const(char)* FC_FONT_HAS_HINT      = "fonthashint";    /* Bool - true if font has hinting */
enum const(char)* FC_ORDER              = "order";          /* Integer */
enum const(char)* FC_DESKTOP_NAME       = "desktop";        /* String */
enum const(char)* FC_NAMED_INSTANCE     = "namedinstance";  /* Bool - true if font is named instance */
enum const(char)* FC_FONT_WRAPPER       = "fontwrapper";    /* String */

enum FcResult {
    Match,
    NoMatch,
    TypeMismatch,
    NoId,
    OutOfMemory
}

GlyphType toGlyphType(string typeString) @nogc {
    if (typeString == "CFF")
        return GlyphType.cff;
    
    if (typeString == "TrueType")
        return GlyphType.trueType;
    
    return GlyphType.none;
}

extern(C) extern @nogc:

struct FcConfig;
FcConfig* FcInitLoadConfigAndFonts() nothrow;
void FcConfigDestroy(FcConfig*) nothrow;
bool FcInitBringUptoDate();

struct FcPattern;
FcPattern* FcPatternCreate() nothrow;
void FcPatternDestroy(FcPattern*) nothrow;
FcResult FcPatternGetInteger(const(FcPattern)*, const(char)*, int, ref int) nothrow;
FcResult FcPatternGetDouble(const(FcPattern)*, const(char)*, int, ref double) nothrow;
FcResult FcPatternGetString(const(FcPattern)*, const(char)*, int, ref const(char)*) nothrow;
FcResult FcPatternGetBool(const(FcPattern)*, const(char)*, int, ref bool) nothrow;
FcResult FcPatternGetLangSet(const(FcPattern)*, const(char)*, int, ref FcLangSet*) nothrow;
FcResult FcPatternGetCharSet(const(FcPattern)*, const(char)*, int, ref FcCharSet*) nothrow;

struct FcCharSet;
void FcCharSetDestroy(FcCharSet*) nothrow;
FcCharSet* FcCharSetCopy(FcCharSet*) nothrow;
bool FcCharSetHasChar(const(FcCharSet)*, codepoint);
uint FcCharSetCount(const(FcCharSet)*) nothrow;

struct FcLangSet;
void FcLangSetDestroy(FcLangSet*) nothrow;
bool FcLangSetHasLang(const(FcLangSet)*, const(char)*) nothrow;

struct FcObjectSet {
    int            nobject;
    int            sobject;
    const(ubyte)** objects;
}

void FcObjectSetDestroy(FcObjectSet*) nothrow;
FcObjectSet* FcObjectSetBuild(const(char)* first, ...) nothrow;

struct FcFontSet {
    int         nfont;
    int         sfont;
    FcPattern** fonts;
}

void FcFontSetDestroy(FcFontSet*) nothrow;
FcFontSet* FcFontList(FcConfig*, FcPattern*, FcObjectSet*) nothrow;
