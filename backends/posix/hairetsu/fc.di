/**
    FontConfig Binding

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.fc;
import numem;

extern (C) nothrow @nogc:

alias FcChar8 = ubyte;
alias FcChar16 = ushort;
alias FcChar32 = uint;
alias FcBool = int;

//
//              OPAQUE STRUCTS
//
struct FcCharSet;
struct FcPattern;
struct FcPatternIter;
struct FcLangSet;
struct FcRange;
struct FcConfig;
struct FcFileCache;
struct FcBlanks;
struct FcStrList;
struct FcStrSet;
struct FcCache;

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

enum FcResult {
    FcResultMatch,
    FcResultNoMatch,
    FcResultTypeMismatch,
    FcResultNoId,
    FcResultOutOfMemory
}

enum FcValueBinding {
    FcValueBindingWeak,
    FcValueBindingStrong,
    FcValueBindingSame,
}

enum FcMatchKind {
    FcMatchPattern,
    FcMatchFont,
    FcMatchScan,
}

enum FcEndian {
    FcEndianBig,
    FcEndianLittle
}

//
//          STRUCTS
//

struct FcObjectType {
    char* object;
    FcType type;
}

struct FcConstant {
    const FcChar8* name;
    const char* object;
    int value;
}

struct FcValue {
    FcType type;
    FcValueV value;

    static
    union FcValueV {
        const(ubyte)* s;
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
    int nfont;
    int sfont;
    FcPattern** fonts;
}

struct FcMatrix {
    double xx, xy, yx, yy;
}

//
//          FUNCTIONS
//

// Init
extern FcConfig* FcInitLoadConfigAndFonts();
extern void FcFini();

// Config
extern FcBool FcConfigSubstitute(FcConfig* config,
    FcPattern* p,
    FcMatchKind kind);

// Default
extern FcStrSet* FcGetDefaultLangs();
extern void FcDefaultSubstitute(FcPattern* pattern);

// FontSet
extern FcFontSet* FcFontSetCreate();
extern void FcFontSetDestroy(FcFontSet* s);
extern FcBool FcFontSetAdd(FcFontSet* s, FcPattern* font);

// Langs
extern FcStrSet* FcGetLangs();
extern char* FcLangNormalize(const(char)* lang);
extern const(FcCharSet)* FcLangGetCharSet(const(char)* lang);
extern FcLangSet* FcLangSetCreate();
extern void FcLangSetDestroy(FcLangSet* ls);
extern FcLangSet* FcLangSetCopy(const(FcLangSet)* ls);
extern FcBool FcLangSetAdd(FcLangSet* ls, const(FcChar8)* lang);
extern FcBool FcLangSetDel(FcLangSet* ls, const(FcChar8)* lang);
extern FcLangResult FcLangSetHasLang(const(FcLangSet)* ls, const(FcChar8)* lang);
extern FcLangResult FcLangSetCompare(const(FcLangSet)* lsa, const(FcLangSet)* lsb);
extern FcBool FcLangSetContains(const(FcLangSet)* lsa, const(FcLangSet)* lsb);
extern FcBool FcLangSetEqual(const(FcLangSet)* lsa, const(FcLangSet)* lsb);
extern FcChar32 FcLangSetHash(const(FcLangSet)* ls);
extern FcStrSet* FcLangSetGetLangs(const(FcLangSet)* ls);
extern FcLangSet* FcLangSetUnion(const(FcLangSet)* a, const(FcLangSet)* b);
extern FcLangSet* FcLangSetSubtract(const(FcLangSet)* a, const(FcLangSet)* b);

// Match
extern FcPattern* FcFontSetMatch(FcConfig* config,
    FcFontSet** sets,
    int nsets,
    FcPattern* p,
    FcResult* result);

extern FcPattern* FcFontMatch(FcConfig* config,
    FcPattern* p,
    FcResult* result);

extern FcPattern* FcFontRenderPrepare(FcConfig* config,
    FcPattern* pat,
    FcPattern* font);

extern FcFontSet* FcFontSetSort(FcConfig* config,
    FcFontSet** sets,
    int nsets,
    FcPattern* p,
    FcBool trim,
    FcCharSet** csp,
    FcResult* result);

extern FcFontSet* FcFontSort(FcConfig* config,
    FcPattern* p,
    FcBool trim,
    FcCharSet** csp,
    FcResult* result);

extern void FcFontSetSortDestroy(FcFontSet* fs);

// fclist
extern FcObjectSet* FcObjectSetCreate(void);
extern FcBool FcObjectSetAdd(FcObjectSet* os, const char* object);
extern void FcObjectSetDestroy(FcObjectSet* os);
extern FcObjectSet* FcObjectSetBuild(const char* first, ...);
extern FcFontSet* FcFontSetList(FcConfig* config,
    FcFontSet** sets,
    int nsets,
    FcPattern* p,
    FcObjectSet* os);
extern FcFontSet* FcFontList(FcConfig* config,
    FcPattern* p,
    FcObjectSet* os);

// Patterns
extern FcPattern* FcPatternCreate();
extern FcPattern* FcPatternDuplicate(const(FcPattern)* p);
extern void FcPatternReference(FcPattern* p);
extern FcPattern* FcPatternFilter(FcPattern* p, const(FcObjectSet)* os);
extern void FcValueDestroy(FcValue v);
extern FcBool FcValueEqual(FcValue va, FcValue vb);
extern FcValue FcValueSave(FcValue v);
extern void FcPatternDestroy(FcPattern* p);
extern int FcPatternObjectCount(const(FcPattern)* pat);
extern FcBool FcPatternEqual(const(FcPattern)* pa, const(FcPattern)* pb);
extern FcBool FcPatternEqualSubset(const(FcPattern)* pa, const(FcPattern)* pb, const(FcObjectSet)* os);
extern FcChar32 FcPatternHash(const(FcPattern)* p);
extern FcBool FcPatternAdd(FcPattern* p, const(char)* object, FcValue value, FcBool append);
extern FcBool FcPatternAddWeak(FcPattern* p, const(char)* object, FcValue value, FcBool append);
extern FcResult FcPatternGet(const(FcPattern)* p, const(char)* object, int id, FcValue* v);
extern FcResult FcPatternGetWithBinding(const(FcPattern)* p, const(char)* object, int id, FcValue* v, FcValueBinding* b);
extern FcBool FcPatternDel(FcPattern* p, const(char)* object);
extern FcBool FcPatternRemove(FcPattern* p, const(char)* object, int id);
extern FcBool FcPatternAddInteger(FcPattern* p, const(char)* object, int i);
extern FcBool FcPatternAddDouble(FcPattern* p, const(char)* object, double d);
extern FcBool FcPatternAddString(FcPattern* p, const(char)* object, const(FcChar8)* s);
extern FcBool FcPatternAddMatrix(FcPattern* p, const(char)* object, const(FcMatrix)* s);
extern FcBool FcPatternAddCharSet(FcPattern* p, const(char)* object, const(FcCharSet)* c);
extern FcBool FcPatternAddBool(FcPattern* p, const(char)* object, FcBool b);
extern FcBool FcPatternAddLangSet(FcPattern* p, const(char)* object, const(FcLangSet)* ls);
extern FcBool FcPatternAddRange(FcPattern* p, const(char)* object, const(FcRange)* r);
extern FcResult FcPatternGetInteger(const(FcPattern)* p, const(char)* object, int n, int* i);
extern FcResult FcPatternGetDouble(const(FcPattern)* p, const(char)* object, int n, double* d);
extern FcResult FcPatternGetString(const(FcPattern)* p, const(char)* object, int n, FcChar8** s);
extern FcResult FcPatternGetMatrix(const(FcPattern)* p, const(char)* object, int n, FcMatrix** s);
extern FcResult FcPatternGetCharSet(const(FcPattern)* p, const(char)* object, int n, FcCharSet** c);
extern FcResult FcPatternGetBool(const(FcPattern)* p, const(char)* object, int n, FcBool* b);
extern FcResult FcPatternGetLangSet(const(FcPattern)* p, const(char)* object, int n, FcLangSet** ls);
extern FcResult FcPatternGetRange(const(FcPattern)* p, const(char)* object, int id, FcRange** r);
extern FcPattern* FcPatternBuild(FcPattern* p, ...);
extern FcChar8* FcPatternFormat(FcPattern* pat, const(FcChar8)* format);

// Weight
extern int FcWeightFromOpenType(int ot_weight);
extern double FcWeightFromOpenTypeDouble(double ot_weight);
extern int FcWeightToOpenType(int fc_weight);
extern double FcWeightToOpenTypeDouble(double fc_weight);

// StrSet
extern FcStrSet* FcStrSetCreate();
extern FcBool FcStrSetMember(FcStrSet* set, const(FcChar8)* s);
extern FcBool FcStrSetEqual(FcStrSet* sa, FcStrSet* sb);
extern FcBool FcStrSetAdd(FcStrSet* set, const(FcChar8)* s);
extern FcBool FcStrSetAddFilename(FcStrSet* set, const(FcChar8)* s);
extern FcBool FcStrSetDel(FcStrSet* set, const(FcChar8)* s);
extern void FcStrSetDestroy(FcStrSet* set);

// StrList
extern FcStrList* FcStrListCreate(FcStrSet* set);
extern void FcStrListFirst(FcStrList* list);
extern FcChar8* FcStrListNext(FcStrList* list);
extern void FcStrListDone(FcStrList* list);
