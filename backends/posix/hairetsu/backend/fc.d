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
module hairetsu.backend.fc;
import hairetsu.backend.ft : FT_Face;

extern (C) nothrow @nogc:

alias FcChar8 = char;
alias FcChar16 = wchar;
alias FcChar32 = dchar;
alias FcBool = bool;
alias FcString = const(char)*;

//
//          ENUMERATIONS
//
enum FcString FC_FAMILY =                  "family";		    /** String */
enum FcString FC_STYLE =                   "style";		        /** String */
enum FcString FC_SLANT =                   "slant";		        /** Int */
enum FcString FC_WEIGHT =                  "weight";		        /** Int */
enum FcString FC_SIZE =                    "size";		        /** Range (double) */
enum FcString FC_ASPECT =                  "aspect";		        /** Double */
enum FcString FC_PIXEL_SIZE =              "pixelsize";		    /** Double */
enum FcString FC_SPACING =                 "spacing";		    /** Int */
enum FcString FC_FOUNDRY =                 "foundry";		    /** String */
enum FcString FC_ANTIALIAS =               "antialias";		    /** Bool (depends) */
enum FcString FC_HINTING =                 "hinting";		    /** Bool (true) */
enum FcString FC_HINT_STYLE =              "hintstyle";		    /** Int */
enum FcString FC_VERTICAL_LAYOUT =         "verticallayout";	    /** Bool (false) */
enum FcString FC_AUTOHINT =                "autohint";		    /** Bool (false) */
enum FcString FC_WIDTH =                   "width";		        /** Int */
enum FcString FC_FILE =                    "file";		        /** String */
enum FcString FC_INDEX =                   "index";		        /** Int */
enum FcString FC_FTFACE =                  "ftface";	        /** FT_Face */
enum FcString FC_OUTLINE =                 "outline";		    /** Bool */
enum FcString FC_SCALABLE =                "scalable";		    /** Bool */
enum FcString FC_COLOR =                   "color";		        /** Bool */
enum FcString FC_VARIABLE =                "variable";		    /** Bool */
enum FcString FC_SYMBOL =                  "symbol";		        /** Bool */
enum FcString FC_DPI =                     "dpi";		        /** double */
enum FcString FC_RGBA =                    "rgba";		        /** Int */
enum FcString FC_MINSPACE =                "minspace";		    /** Bool use minimum line spacing */
enum FcString FC_CHARSET =                 "charset";		    /** CharSet */
enum FcString FC_LANG =                    "lang";		        /** LangSet Set of RFC 3066 langs */
enum FcString FC_FONTVERSION =             "fontversion";	    /** Int from 'head' table */
enum FcString FC_FULLNAME =                "fullname";		    /** String */
enum FcString FC_FAMILYLANG =              "familylang";	        /** String RFC 3066 langs */
enum FcString FC_STYLELANG =               "stylelang";		    /** String RFC 3066 langs */
enum FcString FC_FULLNAMELANG =            "fullnamelang";	    /** String RFC 3066 langs */
enum FcString FC_CAPABILITY =              "capability";	        /** String */
enum FcString FC_FONTFORMAT =              "fontformat";	        /** String */
enum FcString FC_EMBOLDEN =                "embolden";		    /** Bool - true if emboldening needed */
enum FcString FC_EMBEDDED_BITMAP =         "embeddedbitmap";	    /** Bool - true to enable embedded bitmaps */
enum FcString FC_DECORATIVE =              "decorative";	        /** Bool - true if style is a decorative variant */
enum FcString FC_LCD_FILTER =              "lcdfilter";		    /** Int */
enum FcString FC_FONT_FEATURES =           "fontfeatures";	    /** String */
enum FcString FC_FONT_VARIATIONS =         "fontvariations";	    /** String */
enum FcString FC_NAMELANG =                "namelang";		    /** String RFC 3866 langs */
enum FcString FC_PRGNAME =                 "prgname";		    /** String */
enum FcString FC_POSTSCRIPT_NAME =         "postscriptname";	    /** String */
enum FcString FC_FONT_HAS_HINT =           "fonthashint";	    /** Bool - true if font has hinting */
enum FcString FC_ORDER =                   "order";		        /** Integer */
enum FcString FC_DESKTOP_NAME =            "desktop";		    /** String */
enum FcString FC_NAMED_INSTANCE =          "namedinstance";	    /** Bool - true if font is named instance */
enum FcString FC_FONT_WRAPPER =            "fontwrapper"; 	    /** String */
enum const(void)* FC_LIST_END =            null;

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
    Match,
    NoMatch,
    TypeMismatch,
    NoId,
    OutOfMemory
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

struct FcPatternIter {
    void *dummy1;
    void *dummy2;
} 

enum FcEndian {
    BigEndian,
    LittleEndian
}

alias FcDestroyFunc = void function(void *data);
alias FcFilterFontSetFunc = FcBool function(const(FcPattern)* font, void *user_data);

// Opaque pointers
struct FcAtomic;
struct FcConfig;
struct FcFileCache;
struct FcBlanks;
struct FcStrList;
struct FcStrSet;
struct FcCache;
struct FcLangSet;
struct FcRange;
struct FcPattern;
struct FcCharSet;

/* fcblanks.c */
FcBlanks* FcBlanksCreate ();
void FcBlanksDestroy (FcBlanks *b);
FcBool FcBlanksAdd (FcBlanks *b, FcChar32 ucs4);
FcBool FcBlanksIsMember (FcBlanks *b, FcChar32 ucs4);

/* fccache.c */

const(FcChar8)* FcCacheDir (const(FcCache)* c);
FcFontSet* FcCacheCopySet (const(FcCache)* c);
const(FcChar8)* FcCacheSubdir (const(FcCache)* c, int i);
int FcCacheNumSubdir (const(FcCache)* c);
int FcCacheNumFont (const(FcCache)* c);
FcBool FcDirCacheUnlink (const(FcChar8)* dir, FcConfig *config);
FcBool FcDirCacheValid (const(FcChar8)* cache_file);
FcBool FcDirCacheClean (const(FcChar8)* cache_dir, FcBool verbose);
void FcCacheCreateTagFile (FcConfig *config);
FcBool FcDirCacheCreateUUID (FcChar8  *dir,
                      FcBool    force,
                      FcConfig *config);
FcBool FcDirCacheDeleteUUID (const(FcChar8)* dir,
                      FcConfig      *config);

/* fccfg.c */
FcChar8* FcConfigHome ();
FcBool FcConfigEnableHome (FcBool enable);
FcChar8* FcConfigGetFilename (FcConfig      *config,
                     const(FcChar8)* url);
FcChar8* FcConfigFilename (const(FcChar8)* url);
FcConfig* FcConfigCreate ();
FcConfig* FcConfigReference (FcConfig *config);
void FcConfigDestroy (FcConfig *config);
FcBool FcConfigSetCurrent (FcConfig *config);
FcConfig* FcConfigGetCurrent ();
FcBool FcConfigUptoDate (FcConfig *config);
FcBool FcConfigBuildFonts (FcConfig *config);
FcStrList* FcConfigGetFontDirs (FcConfig *config);
FcStrList* FcConfigGetConfigDirs (FcConfig *config);
FcStrList* FcConfigGetConfigFiles (FcConfig *config);
FcChar8* FcConfigGetCache (FcConfig *config);
FcBlanks* FcConfigGetBlanks (FcConfig *config);
FcStrList* FcConfigGetCacheDirs (FcConfig *config);
int FcConfigGetRescanInterval (FcConfig *config);
FcBool FcConfigSetRescanInterval (FcConfig *config, int rescanInterval);
FcFontSet* FcConfigGetFonts (FcConfig *config,
                  FcSetName set);
FcBool FcConfigAcceptFont (FcConfig        *config,
                    const(FcPattern)* font);
FcBool FcConfigAcceptFilter (FcConfig        *config,
                      const(FcPattern)* font);
FcBool FcConfigAppFontAddFile (FcConfig      *config,
                        const(FcChar8)* file);
FcBool FcConfigAppFontAddDir (FcConfig      *config,
                       const(FcChar8)* dir);
void FcConfigAppFontClear (FcConfig *config);
FcBool FcConfigSubstituteWithPat (FcConfig   *config,
                           FcPattern  *p,
                           FcPattern  *p_pat,
                           FcMatchKind kind);
FcBool FcConfigSubstitute (FcConfig   *config,
                    FcPattern  *p,
                    FcMatchKind kind);
const(FcChar8)* FcConfigGetSysRoot (const(FcConfig)* config);
void FcConfigSetSysRoot (FcConfig      *config,
                    const(FcChar8)* sysroot);
FcConfig* FcConfigSetFontSetFilter (FcConfig           *config,
                          FcFilterFontSetFunc filter_func,
                          FcDestroyFunc       destroy_data_func,
                          void               *user_data);
void FcConfigFileInfoIterInit (FcConfig             *config,
                          FcConfigFileInfoIter *iter);
FcBool FcConfigFileInfoIterNext (FcConfig             *config,
                          FcConfigFileInfoIter *iter);
FcBool FcConfigFileInfoIterGet (FcConfig             *config,
                         FcConfigFileInfoIter *iter,
                         FcChar8             **name,
                         FcChar8             **description,
                         FcBool               *enabled);

/* fccharset.c */
enum FC_CHARSET_MAP_SIZE = (256 / 32);
enum FC_CHARSET_DONE =     (cast(FcChar32) - 1);

FcCharSet* FcCharSetCreate ();
void FcCharSetDestroy (FcCharSet *fcs);
FcBool FcCharSetAddChar (FcCharSet *fcs, FcChar32 ucs4);
FcBool FcCharSetDelChar (FcCharSet *fcs, FcChar32 ucs4);
FcCharSet* FcCharSetCopy (FcCharSet *src);
FcBool FcCharSetEqual (const(FcCharSet)* a, const(FcCharSet)* b);
FcCharSet* FcCharSetIntersect (const(FcCharSet)* a, const(FcCharSet)* b);
FcCharSet* FcCharSetUnion (const(FcCharSet)* a, const(FcCharSet)* b);
FcCharSet* FcCharSetSubtract (const(FcCharSet)* a, const(FcCharSet)* b);
FcBool FcCharSetMerge (FcCharSet *a, const(FcCharSet)* b, FcBool *changed);
FcBool FcCharSetHasChar (const(FcCharSet)* fcs, FcChar32 ucs4);
FcChar32 FcCharSetCount (const(FcCharSet)* a);
FcChar32 FcCharSetIntersectCount (const(FcCharSet)* a, const(FcCharSet)* b);
FcChar32 FcCharSetSubtractCount (const(FcCharSet)* a, const(FcCharSet)* b);
FcBool FcCharSetIsSubset (const(FcCharSet)* a, const(FcCharSet)* b);
FcChar32 FcCharSetFirstPage (const(FcCharSet)* a, FcChar32[FC_CHARSET_MAP_SIZE] map, FcChar32* next);
FcChar32 FcCharSetNextPage (const(FcCharSet)* a, FcChar32[FC_CHARSET_MAP_SIZE] map, FcChar32* next);

/* fcdbg.c */
void FcValuePrint (const FcValue v);
void FcPatternPrint (const(FcPattern)* p);
void FcFontSetPrint (const(FcFontSet)* s);

/* fcdefault.c */
FcStrSet* FcGetDefaultLangs ();
void FcDefaultSubstitute (FcPattern *pattern);

/* fcdir.c */
FcBool FcFileIsDir (const(FcChar8)* file);
FcBool FcFileScan (FcFontSet     *set,
            FcStrSet      *dirs,
            FcFileCache   *cache,
            FcBlanks      *blanks,
            const(FcChar8)* file,
            FcBool         force);
FcBool FcDirScan (FcFontSet     *set,
           FcStrSet      *dirs,
           FcFileCache   *cache,
           FcBlanks      *blanks,
           const(FcChar8)* dir,
           FcBool         force);
FcBool FcDirSave (FcFontSet *set, FcStrSet *dirs, const(FcChar8)* dir);
FcCache* FcDirCacheLoad (const(FcChar8)* dir, FcConfig *config, FcChar8 **cache_file);
FcCache* FcDirCacheRescan (const(FcChar8)* dir, FcConfig *config);
FcCache* FcDirCacheRead (const(FcChar8)* dir, FcBool force, FcConfig *config);
FcCache* FcDirCacheLoadFile (const(FcChar8)* cache_file, void* file_stat);
void FcDirCacheUnload (FcCache *cache);

/* fcfreetype.c */
FcPattern* FcFreeTypeQuery (const(FcChar8)* file, uint id, FcBlanks *blanks, int *count);
uint FcFreeTypeQueryAll (const(FcChar8)* file, uint id, FcBlanks *blanks, int *count, FcFontSet *set);
FcResult FcPatternGetFTFace (const (FcPattern) *p, const (char) *object, int n, FT_Face *f);
FcBool FcPatternAddFTFace (FcPattern *p, const (char) *object, const FT_Face f);
FcPattern* FcFreeTypeQueryFace (const (FT_Face)  face,
                     const(FcChar8)* file,
                     uint   id,
                     FcBlanks      *blanks);


/* fcfs.c */
FcFontSet* FcFontSetCreate ();
void FcFontSetDestroy (FcFontSet *s);
FcBool FcFontSetAdd (FcFontSet *s, FcPattern *font);

/* fcinit.c */
FcConfig* FcInitLoadConfig ();
FcConfig* FcInitLoadConfigAndFonts ();
FcBool FcInit ();
void FcFini ();
int FcGetVersion ();
FcBool FcInitReinitialize ();
FcBool FcInitBringUptoDate ();

/* fclang.c */
FcStrSet* FcGetLangs ();
FcChar8* FcLangNormalize (const(FcChar8)* lang);
const(FcCharSet)* FcLangGetCharSet (const(FcChar8)* lang);
FcLangSet* FcLangSetCreate ();
void FcLangSetDestroy (FcLangSet *ls);
FcLangSet* FcLangSetCopy (const(FcLangSet)* ls);
FcBool FcLangSetAdd (FcLangSet *ls, const(FcChar8)* lang);
FcBool FcLangSetDel (FcLangSet *ls, const(FcChar8)* lang);
FcLangResult FcLangSetHasLang (const(FcLangSet)* ls, const(FcChar8)* lang);
FcLangResult FcLangSetCompare (const(FcLangSet)* lsa, const(FcLangSet)* lsb);
FcBool FcLangSetContains (const(FcLangSet)* lsa, const(FcLangSet)* lsb);
FcBool FcLangSetEqual (const(FcLangSet)* lsa, const(FcLangSet)* lsb);
FcChar32 FcLangSetHash (const(FcLangSet)* ls);
FcStrSet* FcLangSetGetLangs (const(FcLangSet)* ls);
FcLangSet* FcLangSetUnion (const(FcLangSet)* a, const(FcLangSet)* b);
FcLangSet* FcLangSetSubtract (const(FcLangSet)* a, const(FcLangSet)* b);

/* fclist.c */
FcObjectSet* FcObjectSetCreate ();
FcBool FcObjectSetAdd (FcObjectSet *os, const(char)* object);
void FcObjectSetDestroy (FcObjectSet *os);
FcObjectSet* FcObjectSetBuild (const(char)* first, ...);
FcFontSet* FcFontSetList (FcConfig    *config,
               FcFontSet  **sets,
               int          nsets,
               FcPattern   *p,
               FcObjectSet *os);
FcFontSet* FcFontList (FcConfig    *config,
            FcPattern   *p,
            FcObjectSet *os);

/* fcatomic.c */
FcAtomic* FcAtomicCreate (const(FcChar8)* file);
FcBool FcAtomicLock (FcAtomic *atomic);
FcChar8* FcAtomicNewFile (FcAtomic *atomic);
FcChar8* FcAtomicOrigFile (FcAtomic *atomic);
FcBool FcAtomicReplaceOrig (FcAtomic *atomic);
void FcAtomicDeleteNew (FcAtomic *atomic);
void FcAtomicUnlock (FcAtomic *atomic);
void FcAtomicDestroy (FcAtomic *atomic);

/* fcmatch.c */
FcPattern* FcFontSetMatch (FcConfig   *config,
                FcFontSet **sets,
                int         nsets,
                FcPattern  *p,
                FcResult   *result);
FcPattern* FcFontMatch (FcConfig  *config,
             FcPattern *p,
             FcResult  *result);
FcPattern* FcFontRenderPrepare (FcConfig  *config,
                     FcPattern *pat,
                     FcPattern *font);
FcFontSet* FcFontSetSort (FcConfig   *config,
               FcFontSet **sets,
               int         nsets,
               FcPattern  *p,
               FcBool      trim,
               FcCharSet **csp,
               FcResult   *result);
FcFontSet* FcFontSort (FcConfig   *config,
            FcPattern  *p,
            FcBool      trim,
            FcCharSet **csp,
            FcResult   *result);
void FcFontSetSortDestroy (FcFontSet *fs);

/* fcmatrix.c */
FcMatrix* FcMatrixCopy (const(FcMatrix)* mat);
FcBool FcMatrixEqual (const(FcMatrix)* mat1, const(FcMatrix)* mat2);
void FcMatrixMultiply (FcMatrix *result, const(FcMatrix)* a, const(FcMatrix)* b);
void FcMatrixRotate (FcMatrix *m, double c, double s);
void FcMatrixScale (FcMatrix *m, double sx, double sy);
void FcMatrixShear (FcMatrix *m, double sh, double sv);

/* fcname.c */
const(FcObjectType)* FcNameGetObjectType (const(char)* object);
const(FcConstant)* FcNameGetConstant (const(FcChar8)* string);
const(FcConstant)* FcNameGetConstantFor (const(FcChar8)* string, const(char)* object);
FcBool FcNameConstant (const(FcChar8)* string, int *result);
FcPattern* FcNameParse (const(FcChar8)* name);
FcChar8* FcNameUnparse (FcPattern *pat);

/* fcpat.c */
FcPattern* FcPatternCreate ();
FcPattern* FcPatternDuplicate (const(FcPattern)* p);
void FcPatternReference (FcPattern *p);
FcPattern* FcPatternFilter (FcPattern *p, const(FcObjectSet)* os);
void FcValueDestroy (FcValue v);
FcBool FcValueEqual (FcValue va, FcValue vb);
FcValue FcValueSave (FcValue v);
void FcPatternDestroy (FcPattern *p);
int FcPatternObjectCount (const(FcPattern)* pat);
FcBool FcPatternEqual (const(FcPattern)* pa, const(FcPattern)* pb);
FcBool FcPatternEqualSubset (const(FcPattern)* pa, const(FcPattern)* pb, const(FcObjectSet)* os);
FcChar32 FcPatternHash (const(FcPattern)* p);
FcBool FcPatternAdd (FcPattern *p, const(char)* object, FcValue value, FcBool append);
FcBool FcPatternAddWeak (FcPattern *p, const(char)* object, FcValue value, FcBool append);
FcResult FcPatternGet (const(FcPattern)* p, const(char)* object, int id, FcValue *v);
FcResult FcPatternGetWithBinding (const(FcPattern)* p, const(char)* object, int id, FcValue *v, FcValueBinding *b);
FcBool FcPatternDel (FcPattern *p, const(char)* object);
FcBool FcPatternRemove (FcPattern *p, const(char)* object, int id);
FcBool FcPatternAddInteger (FcPattern *p, const(char)* object, int i);
FcBool FcPatternAddDouble (FcPattern *p, const(char)* object, double d);
FcBool FcPatternAddString (FcPattern *p, const(char)* object, const(FcChar8)* s);
FcBool FcPatternAddMatrix (FcPattern *p, const(char)* object, const(FcMatrix)* s);
FcBool FcPatternAddCharSet (FcPattern *p, const(char)* object, const(FcCharSet)* c);
FcBool FcPatternAddBool (FcPattern *p, const(char)* object, FcBool b);
FcBool FcPatternAddLangSet (FcPattern *p, const(char)* object, const(FcLangSet)* ls);
FcBool FcPatternAddRange (FcPattern *p, const(char)* object, const(FcRange)* r);
FcResult FcPatternGetInteger (const(FcPattern)* p, const(char)* object, int n, int *i);
FcResult FcPatternGetDouble (const(FcPattern)* p, const(char)* object, int n, double *d);
FcResult FcPatternGetString (const(FcPattern)* p, const(char)* object, int n, FcChar8 **s);
FcResult FcPatternGetMatrix (const(FcPattern)* p, const(char)* object, int n, FcMatrix **s);
FcResult FcPatternGetCharSet (const(FcPattern)* p, const(char)* object, int n, FcCharSet **c);
FcResult FcPatternGetBool (const(FcPattern)* p, const(char)* object, int n, FcBool *b);
FcResult FcPatternGetLangSet (const(FcPattern)* p, const(char)* object, int n, FcLangSet **ls);
FcResult FcPatternGetRange (const(FcPattern)* p, const(char)* object, int id, FcRange **r);
FcPattern* FcPatternBuild (FcPattern *p, ...);
FcChar8* FcPatternFormat (FcPattern *pat, const(FcChar8)* format);

// D API
string getPatternStr(FcPattern* pattern, const(char)* group, int n = 0) {
    import nulib.string : nu_strlen;

    const(char)* tmp;
    if (FcPatternGetString(pattern, group, n, cast(char**)&tmp) == FcResult.Match) {
        return cast(string)tmp[0..nu_strlen(tmp)];
    }
    return null;
}

int getPatternInteger(FcPattern* pattern, const(char)* group, int n = 0) {
    int tmp;
    FcPatternGetInteger(pattern, group, n, &tmp);
    
    return tmp;
}

double getPatternDouble(FcPattern* pattern, const(char)* group, int n = 0) {
    double tmp;

    FcPatternGetDouble(pattern, group, n, &tmp);
    return tmp;
}

bool getPatternBool(FcPattern* pattern, const(char)* group, int n = 0) {
    bool tmp;
    FcPatternGetBool(pattern, group, n, &tmp);
    return tmp;
}

/* fcrange.c */
FcRange* FcRangeCreateDouble (double begin, double end);
FcRange* FcRangeCreateInteger (FcChar32 begin, FcChar32 end);
void FcRangeDestroy (FcRange *range);
FcRange* FcRangeCopy (const(FcRange)* r);
FcBool FcRangeGetDouble (const(FcRange)* range, double *begin, double *end);
void FcPatternIterStart (const(FcPattern)* pat, FcPatternIter *iter);
FcBool FcPatternIterNext (const(FcPattern)* pat, FcPatternIter *iter);
FcBool FcPatternIterEqual (const(FcPattern)* p1, FcPatternIter *i1,
                    const(FcPattern)* p2, FcPatternIter *i2);
FcBool FcPatternFindIter (const(FcPattern)* pat, FcPatternIter *iter, const(char)* object);
FcBool FcPatternIterIsValid (const(FcPattern)* pat, FcPatternIter *iter);
const(char)* FcPatternIterGetObject (const(FcPattern)* pat, FcPatternIter *iter);
int FcPatternIterValueCount (const(FcPattern)* pat, FcPatternIter *iter);
FcResult FcPatternIterGetValue (const(FcPattern)* pat, FcPatternIter *iter, int id, FcValue *v, FcValueBinding *b);

/* fcweight.c */
int FcWeightFromOpenType (int ot_weight);
double FcWeightFromOpenTypeDouble (double ot_weight);
int FcWeightToOpenType (int fc_weight);
double FcWeightToOpenTypeDouble (double fc_weight);

/* fcstr.c */
enum FC_UTF8_MAX_LEN = 6;

FcChar8* FcStrCopy (const(FcChar8)* s);
FcChar8* FcStrCopyFilename (const(FcChar8)* s);
FcChar8* FcStrPlus (const(FcChar8)* s1, const(FcChar8)* s2);
void FcStrFree (FcChar8 *s);
FcChar8* FcStrDowncase (const(FcChar8)* s);
int FcStrCmpIgnoreCase (const(FcChar8)* s1, const(FcChar8)* s2);
int FcStrCmp (const(FcChar8)* s1, const(FcChar8)* s2);
const(FcChar8)* FcStrStrIgnoreCase (const(FcChar8)* s1, const(FcChar8)* s2);
const(FcChar8)* FcStrStr (const(FcChar8)* s1, const(FcChar8)* s2);
int FcUtf8ToUcs4 (const(FcChar8)* src_orig,
              FcChar32      *dst,
              int            len);
FcBool FcUtf8Len (const(FcChar8)* string,
           int            len,
           int           *nchar,
           int           *wchar_);
int FcUcs4ToUtf8 (FcChar32 ucs4, FcChar8[FC_UTF8_MAX_LEN] dest);
int FcUtf16ToUcs4 (const(FcChar8)* src_orig,
               FcEndian       endian,
               FcChar32      *dst,
               int            len); /* in bytes */
FcBool FcUtf16Len (const(FcChar8)* string,
            FcEndian       endian,
            int            len, /* in bytes */
            int           *nchar,
            int           *wchar_);
FcChar8* FcStrBuildFilename (const(FcChar8)* path,
                    ...);
FcChar8* FcStrDirname (const(FcChar8)* file);
FcChar8* FcStrBasename (const(FcChar8)* file);
FcStrSet* FcStrSetCreate ();
FcBool FcStrSetMember (FcStrSet *set, const(FcChar8)* s);
FcBool FcStrSetEqual (FcStrSet *sa, FcStrSet *sb);
FcBool FcStrSetAdd (FcStrSet *set, const(FcChar8)* s);
FcBool FcStrSetAddFilename (FcStrSet *set, const(FcChar8)* s);
FcBool FcStrSetDel (FcStrSet *set, const(FcChar8)* s);
void FcStrSetDestroy (FcStrSet *set);
FcStrList* FcStrListCreate (FcStrSet *set);
void FcStrListFirst (FcStrList *list);
FcChar8* FcStrListNext (FcStrList *list);
void FcStrListDone (FcStrList *list);

/* fcxml.c */
FcBool FcConfigParseAndLoad (FcConfig *config, const(FcChar8)* file, FcBool complain);
FcBool FcConfigParseAndLoadFromMemory (FcConfig      *config,
                                const(FcChar8)* buffer,
                                FcBool         complain);
