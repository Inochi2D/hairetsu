/**
    Adapted from fontconfig.h

    Copyright © 2001 Keith Packard

    This is part of HarfBuzz, a text shaping library.

    Permission is hereby granted, without written agreement and without
    license or royalty fees, to use, copy, modify, and distribute this
    software and its documentation for any purpose, provided that the
    above copyright notice and the following two paragraphs appear in
    all copies of this software.

    IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE TO ANY PARTY FOR
    DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
    ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
    IF THE COPYRIGHT HOLDER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
    DAMAGE.

    THE COPYRIGHT HOLDER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
    BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
    FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
    ON AN "AS IS" BASIS, AND THE COPYRIGHT HOLDER HAS NO OBLIGATION TO
    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

    Authors:
        Keith Packard
        Luna Nielsen
*/
module hairetsu.backend.fc.common;
import hairetsu.backend.fc.range;
import hairetsu.backend.fc.charset;
import hairetsu.backend.fc.pattern;
import hairetsu.backend.fc.lang;

extern (C) nothrow @nogc:

alias FcChar8 = ubyte;
alias FcChar16 = ushort;
alias FcChar32 = uint;
alias FcBool = int;

//
//          ENUMERATIONS
//
enum FC_FAMILY =                  "family";		        /** String */
enum FC_STYLE =                   "style";		        /** String */
enum FC_SLANT =                   "slant";		        /** Int */
enum FC_WEIGHT =                  "weight";		        /** Int */
enum FC_SIZE =                    "size";		        /** Range (double) */
enum FC_ASPECT =                  "aspect";		        /** Double */
enum FC_PIXEL_SIZE =              "pixelsize";		    /** Double */
enum FC_SPACING =                 "spacing";		    /** Int */
enum FC_FOUNDRY =                 "foundry";		    /** String */
enum FC_ANTIALIAS =               "antialias";		    /** Bool (depends) */
enum FC_HINTING =                 "hinting";		    /** Bool (true) */
enum FC_HINT_STYLE =              "hintstyle";		    /** Int */
enum FC_VERTICAL_LAYOUT =         "verticallayout";	    /** Bool (false) */
enum FC_AUTOHINT =                "autohint";		    /** Bool (false) */
enum FC_WIDTH =                   "width";		        /** Int */
enum FC_FILE =                    "file";		        /** String */
enum FC_INDEX =                   "index";		        /** Int */
enum FC_OUTLINE =                 "outline";		    /** Bool */
enum FC_SCALABLE =                "scalable";		    /** Bool */
enum FC_COLOR =                   "color";		        /** Bool */
enum FC_VARIABLE =                "variable";		    /** Bool */
enum FC_SYMBOL =                  "symbol";		        /** Bool */
enum FC_DPI =                     "dpi";		        /** double */
enum FC_RGBA =                    "rgba";		        /** Int */
enum FC_MINSPACE =                "minspace";		    /** Bool use minimum line spacing */
enum FC_CHARSET =                 "charset";		    /** CharSet */
enum FC_LANG =                    "lang";		        /** LangSet Set of RFC 3066 langs */
enum FC_FONTVERSION =             "fontversion";	    /** Int from 'head' table */
enum FC_FULLNAME =                "fullname";		    /** String */
enum FC_FAMILYLANG =              "familylang";	        /** String RFC 3066 langs */
enum FC_STYLELANG =               "stylelang";		    /** String RFC 3066 langs */
enum FC_FULLNAMELANG =            "fullnamelang";	    /** String RFC 3066 langs */
enum FC_CAPABILITY =              "capability";	        /** String */
enum FC_FONTFORMAT =              "fontformat";	        /** String */
enum FC_EMBOLDEN =                "embolden";		    /** Bool - true if emboldening needed */
enum FC_EMBEDDED_BITMAP =         "embeddedbitmap";	    /** Bool - true to enable embedded bitmaps */
enum FC_DECORATIVE =              "decorative";	        /** Bool - true if style is a decorative variant */
enum FC_LCD_FILTER =              "lcdfilter";		    /** Int */
enum FC_FONT_FEATURES =           "fontfeatures";	    /** String */
enum FC_FONT_VARIATIONS =         "fontvariations";	    /** String */
enum FC_NAMELANG =                "namelang";		    /** String RFC 3866 langs */
enum FC_PRGNAME =                 "prgname";		    /** String */
enum FC_POSTSCRIPT_NAME =         "postscriptname";	    /** String */
enum FC_FONT_HAS_HINT =           "fonthashint";	    /** Bool - true if font has hinting */
enum FC_ORDER =                   "order";		        /** Integer */
enum FC_DESKTOP_NAME =            "desktop";		    /** String */
enum FC_NAMED_INSTANCE =          "namedinstance";	    /** Bool - true if font is named instance */
enum FC_FONT_WRAPPER =            "fontwrapper"; 	    /** String */

enum FC_WEIGHT_THIN =          0;
enum FC_WEIGHT_EXTRALIGHT =    40;
enum FC_WEIGHT_ULTRALIGHT =    FC_WEIGHT_EXTRALIGHT;
enum FC_WEIGHT_LIGHT =         50;
enum FC_WEIGHT_DEMILIGHT =     55;
enum FC_WEIGHT_SEMILIGHT =     FC_WEIGHT_DEMILIGHT;
enum FC_WEIGHT_BOOK =          75;
enum FC_WEIGHT_REGULAR =       80;
enum FC_WEIGHT_NORMAL =        FC_WEIGHT_REGULAR;
enum FC_WEIGHT_MEDIUM =        100;
enum FC_WEIGHT_DEMIBOLD =      180;
enum FC_WEIGHT_SEMIBOLD =      FC_WEIGHT_DEMIBOLD;
enum FC_WEIGHT_BOLD =          200;
enum FC_WEIGHT_EXTRABOLD =     205;
enum FC_WEIGHT_ULTRABOLD =     FC_WEIGHT_EXTRABOLD;
enum FC_WEIGHT_BLACK =         210;
enum FC_WEIGHT_HEAVY =         FC_WEIGHT_BLACK;
enum FC_WEIGHT_EXTRABLACK =    215;
enum FC_WEIGHT_ULTRABLACK =    FC_WEIGHT_EXTRABLACK;

enum FC_SLANT_ROMAN =          0;
enum FC_SLANT_ITALIC =         100;
enum FC_SLANT_OBLIQUE =        110;

enum FC_WIDTH_ULTRACONDENSED = 50;
enum FC_WIDTH_EXTRACONDENSED = 63;
enum FC_WIDTH_CONDENSED =      75;
enum FC_WIDTH_SEMICONDENSED =  87;
enum FC_WIDTH_NORMAL =         100;
enum FC_WIDTH_SEMIEXPANDED =   113;
enum FC_WIDTH_EXPANDED =       125;
enum FC_WIDTH_EXTRAEXPANDED =  150;
enum FC_WIDTH_ULTRAEXPANDED =  200;

enum FC_PROPORTIONAL =         0;
enum FC_DUAL =                 90;
enum FC_MONO =                 100;
enum FC_CHARCELL =             110;

/* sub-pixel order */
enum FC_RGBA_UNKNOWN =         0;
enum FC_RGBA_RGB =             1;
enum FC_RGBA_BGR =             2;
enum FC_RGBA_VRGB =            3;
enum FC_RGBA_VBGR =            4;
enum FC_RGBA_NONE =            5;

/* hinting style */
enum FC_HINT_NONE =            0;
enum FC_HINT_SLIGHT =          1;
enum FC_HINT_MEDIUM =          2;
enum FC_HINT_FULL =            3;

/* LCD filter */
enum FC_LCD_NONE =             0;
enum FC_LCD_DEFAULT =          1;
enum FC_LCD_LIGHT =            2;
enum FC_LCD_LEGACY =           3;

enum FcType {
    FcTypeUnknown = -1,
    FcTypeVoid,
    FcTypeInteger,
    FcTypeDouble,
    FcTypeString,
    FcTypeBool,
    FcTypeMatrix,
    FcTypeCharSet,
    FcTypeFTFace,
    FcTypeLangSet,
    FcTypeRange
}

struct FcObjectType {
    ubyte* object;
    FcType type;
}

struct FcConstant {
    const(char)*    name;
    const(ubyte)*   object;
    int             value;
}

enum FcResult {
    FcResultMatch,
    FcResultNoMatch,
    FcResultTypeMismatch,
    FcResultNoId,
    FcResultOutOfMemory
}

enum FcValueBinding : uint {
    FcValueBindingWeak,
    FcValueBindingStrong,
    FcValueBindingSame,
}

struct FcMatrix {
    double xx;
    double xy;
    double yx;
    double yy;
}

struct FcValue {
    FcType type;
    union {
        const(FcChar8)* s;
        int i;
        FcBool b;
        double d;
        const(FcMatrix)* m;
        const(FcCharSet)* c;
        void* f;
        const(FcLangSet)* l;
        const(FcRange)* r;
    }
}

struct FcFontSet {
    int         nfont;
    int         sfont;
    FcPattern** fonts;
}

struct FcObjectSet {
    int             nobject;
    int             sobject;
    const(ubyte)**  objects;
}

enum FcMatchKind {
    FcMatchPattern,
    FcMatchFont,
    FcMatchScan,
    FcMatchKindEnd,
    FcMatchKindBegin = FcMatchPattern
}

enum FcLangResult {
    FcLangEqual = 0,
    FcLangDifferentCountry = 1,
    FcLangDifferentTerritory = 1,
    FcLangDifferentLang = 2
}

enum FcSetName {
    FcSetSystem = 0,
    FcSetApplication = 1
}

struct FcConfigFileInfoIter {
    void *dummy1;
    void *dummy2;
    void *dummy3;
} 

alias FcDestroyFunc = void function(void *data);
alias FcFilterFontSetFunc = FcBool function(const(FcPattern)* font, void *user_data);


