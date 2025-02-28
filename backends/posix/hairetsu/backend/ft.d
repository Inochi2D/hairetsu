/**
    Adapted from freetype.h and fttypes.h

    Copyright (C) 1996-2024 by
    David Turner, Robert Wilhelm, and Werner Lemberg.

    This file is part of the FreeType project, and may only be used,
    modified, and distributed under the terms of the FreeType project
    license, LICENSE.TXT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.

    Authors:
        David Turner
        Robert Wilhelm
        Werner Lemberg
        Luna Nielsen
*/
module hairetsu.backend.ft;

extern(C) nothrow @nogc:

alias FT_Bool = bool;
alias FT_FWord = short;
alias FT_UFWord = ushort;
alias FT_Char = char;
alias FT_Byte = ubyte;
alias FT_Bytes = const(ubyte)*;
alias FT_Tag = uint;
alias FT_String = char;
alias FT_Short = short;
alias FT_UShort = ushort;
alias FT_Int = int;
alias FT_UInt = uint;
alias FT_Long = long;
alias FT_ULong = ulong;
alias FT_F2Dot14 = short;
alias FT_F26Dot6 = long;
alias FT_Fixed = long;
alias FT_Error = int;
alias FT_Pointer = void*;
alias FT_Pos = long;
alias FT_Offset = size_t;
alias FT_PtrDist = ptrdiff_t;

struct FT_Vector {
    FT_Pos  x;
    FT_Pos  y;
}

struct FT_BBox {
    FT_Pos  xMin, yMin;
    FT_Pos  xMax, yMax;
}

enum FT_Pixel_Mode {
    FT_PIXEL_MODE_NONE = 0,
    FT_PIXEL_MODE_MONO,
    FT_PIXEL_MODE_GRAY,
    FT_PIXEL_MODE_GRAY2,
    FT_PIXEL_MODE_GRAY4,
    FT_PIXEL_MODE_LCD,
    FT_PIXEL_MODE_LCD_V,
    FT_PIXEL_MODE_BGRA,

    FT_PIXEL_MODE_MAX      /* do not remove */
}

struct FT_UnitVector {
    FT_F2Dot14  x;
    FT_F2Dot14  y;
}

struct  FT_Matrix {
    FT_Fixed  xx, xy;
    FT_Fixed  yx, yy;
}

struct FT_Data {
    const(FT_Byte)*  pointer;
    FT_UInt          length;
}

alias FT_Generic_Finalizer = void function(void* object);

struct  FT_Generic {
    void*                 data;
    FT_Generic_Finalizer  finalizer;
}

alias FT_ListNode = FT_ListNodeRec*;
alias FT_List = FT_ListRec*;

struct  FT_ListNodeRec {
    FT_ListNode  prev;
    FT_ListNode  next;
    void*        data;
}

struct FT_ListRec {
    FT_ListNode  head;
    FT_ListNode  tail;
}

struct FT_Glyph_Metrics {
    FT_Pos  width;
    FT_Pos  height;

    FT_Pos  horiBearingX;
    FT_Pos  horiBearingY;
    FT_Pos  horiAdvance;

    FT_Pos  vertBearingX;
    FT_Pos  vertBearingY;
    FT_Pos  vertAdvance;
}

struct  FT_Bitmap_Size {
    FT_Short  height;
    FT_Short  width;

    FT_Pos    size;

    FT_Pos    x_ppem;
    FT_Pos    y_ppem;
} 


struct FT_LibraryRec;
alias FT_Library = FT_LibraryRec*;

struct FT_ModuleRec;
alias FT_Module = FT_ModuleRec*;

struct FT_DriverRec;
alias FT_Driver = FT_DriverRec*;

struct FT_RendererRec;
alias FT_Renderer = FT_RendererRec*;

struct FT_SizeRec;
alias FT_Size = FT_SizeRec*;

struct FT_StreamRec;
alias FT_Stream = FT_StreamRec*;

alias FT_Face = FT_FaceRec*;
alias FT_CharMap = FT_CharMapRec*;
alias FT_GlyphSlot = FT_GlyphSlotRec*;
alias FT_Size_Request = FT_Size_RequestRec*;

enum FT_Glyph_Format {
    FT_GLYPH_FORMAT_NONE = 0x00000000u,

    FT_GLYPH_FORMAT_COMPOSITE = FT_TAG!("comp"),
    FT_GLYPH_FORMAT_BITMAP = FT_TAG!("bits"),
    FT_GLYPH_FORMAT_OUTLINE = FT_TAG!("outl"),
    FT_GLYPH_FORMAT_PLOTTER = FT_TAG!("plot"),
    FT_GLYPH_FORMAT_SVG = FT_TAG!("SVG ")
}


enum uint FT_TAG(immutable(char)[4] tag) = (
    ((cast(uint)(tag[0]) & 0xFF) << 24) | 
    ((cast(uint)(tag[1]) & 0xFF) << 16) | 
    ((cast(uint)(tag[2]) & 0xFF) << 8) |
     (cast(uint)(tag[3]) & 0xFF)
);

enum FT_Encoding : uint {
    FT_ENCODING_NONE            = 0x00000000,
    FT_ENCODING_MS_SYMBOL       = FT_TAG!("symb"),
    FT_ENCODING_UNICODE         = FT_TAG!("unic"),
    FT_ENCODING_SJIS            = FT_TAG!("sjis"),
    FT_ENCODING_PRC             = FT_TAG!("gb  "),
    FT_ENCODING_BIG5            = FT_TAG!("big5"),
    FT_ENCODING_WANSUNG         = FT_TAG!("wans"),
    FT_ENCODING_JOHAB           = FT_TAG!("joha"),
    FT_ENCODING_ADOBE_STANDARD  = FT_TAG!("ADOB"),
    FT_ENCODING_ADOBE_EXPERT    = FT_TAG!("ADBE"),
    FT_ENCODING_ADOBE_CUSTOM    = FT_TAG!("ADBC"),
    FT_ENCODING_ADOBE_LATIN_1   = FT_TAG!("lat1"),
    FT_ENCODING_OLD_LATIN_2     = FT_TAG!("lat2"),
    FT_ENCODING_APPLE_ROMAN     = FT_TAG!("armn"),

    FT_ENCODING_GB2312          = FT_ENCODING_PRC,
    FT_ENCODING_MS_SJIS         = FT_ENCODING_SJIS,
    FT_ENCODING_MS_GB2312       = FT_ENCODING_PRC,
    FT_ENCODING_MS_BIG5         = FT_ENCODING_BIG5,
    FT_ENCODING_MS_WANSUNG      = FT_ENCODING_WANSUNG,
    FT_ENCODING_MS_JOHAB        = FT_ENCODING_JOHAB,
}

struct FT_CharMapRec {
    FT_Face      face;
    FT_Encoding  encoding;
    FT_UShort    platform_id;
    FT_UShort    encoding_id;
}

struct FT_Face_InternalRec;
alias FT_Face_Internal = FT_Face_InternalRec*;

struct FT_FaceRec {
    FT_Long           num_faces;
    FT_Long           face_index;

    FT_Long           face_flags;
    FT_Long           style_flags;

    FT_Long           num_glyphs;

    FT_String*        family_name;
    FT_String*        style_name;

    FT_Int            num_fixed_sizes;
    FT_Bitmap_Size*   available_sizes;

    FT_Int            num_charmaps;
    FT_CharMap*       charmaps;

    FT_Generic        generic;

    /* The following member variables (down to `underline_thickness`) */
    /* are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
    /* for bitmap fonts.                                              */
    FT_BBox           bbox;

    FT_UShort         units_per_EM;
    FT_Short          ascender;
    FT_Short          descender;
    FT_Short          height;

    FT_Short          max_advance_width;
    FT_Short          max_advance_height;

    FT_Short          underline_position;
    FT_Short          underline_thickness;

    FT_GlyphSlot      glyph;
    FT_Size           size;
    FT_CharMap        charmap;
}

struct  FT_Bitmap {
    uint    rows;
    uint    width;
    int     pitch;
    ubyte*  buffer;
    ushort  num_grays;
    ubyte   pixel_mode;
    ubyte   palette_mode;
    void*   palette;
}

struct FT_Outline {
    ushort   n_contours;  /* number of contours in glyph        */
    ushort   n_points;    /* number of points in the glyph      */

    FT_Vector*       points;      /* the outline's points               */
    ubyte*   tags;        /* the points flags                   */
    ushort*  contours;    /* the contour end points             */

    int              flags;       /* outline masks                      */

}

enum FT_FACE_FLAG_SCALABLE =          ( 1L <<  0 );
enum FT_FACE_FLAG_FIXED_SIZES =       ( 1L <<  1 );
enum FT_FACE_FLAG_FIXED_WIDTH =       ( 1L <<  2 );
enum FT_FACE_FLAG_SFNT =              ( 1L <<  3 );
enum FT_FACE_FLAG_HORIZONTAL =        ( 1L <<  4 );
enum FT_FACE_FLAG_VERTICAL =          ( 1L <<  5 );
enum FT_FACE_FLAG_KERNING =           ( 1L <<  6 );
enum FT_FACE_FLAG_FAST_GLYPHS =       ( 1L <<  7 );
enum FT_FACE_FLAG_MULTIPLE_MASTERS =  ( 1L <<  8 );
enum FT_FACE_FLAG_GLYPH_NAMES =       ( 1L <<  9 );
enum FT_FACE_FLAG_EXTERNAL_STREAM =   ( 1L << 10 );
enum FT_FACE_FLAG_HINTER =            ( 1L << 11 );
enum FT_FACE_FLAG_CID_KEYED =         ( 1L << 12 );
enum FT_FACE_FLAG_TRICKY =            ( 1L << 13 );
enum FT_FACE_FLAG_COLOR =             ( 1L << 14 );
enum FT_FACE_FLAG_VARIATION =         ( 1L << 15 );
enum FT_FACE_FLAG_SVG =               ( 1L << 16 );
enum FT_FACE_FLAG_SBIX =              ( 1L << 17 );
enum FT_FACE_FLAG_SBIX_OVERLAY =      ( 1L << 18 );

bool FT_HAS_HORIZONTAL(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_HORIZONTAL));
}

bool FT_HAS_VERTICAL(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_VERTICAL));
}

bool FT_HAS_KERNING(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_KERNING));
}

bool FT_IS_SCALABLE(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_SCALABLE));
}

bool FT_IS_SFNT(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_SFNT));
}

bool FT_IS_FIXED_WIDTH(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_FIXED_WIDTH));
}

bool FT_HAS_FIXED_SIZES(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_FIXED_SIZES));
}

bool FT_HAS_GLYPH_NAMES(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_GLYPH_NAMES));
}

bool FT_HAS_MULTIPLE_MASTERS(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_MULTIPLE_MASTERS));
}

bool FT_IS_NAMED_INSTANCE(FT_Face face) { 
    return (!!(face.face_flags & 0x7FFF0000L));
}

bool FT_IS_VARIATION(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_VARIATION));
}

bool FT_IS_CID_KEYED(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_CID_KEYED));
}

bool FT_IS_TRICKY(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_TRICKY));
}

bool FT_HAS_COLOR(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_COLOR));
}

bool FT_HAS_SVG(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_SVG));
}

bool FT_HAS_SBIX(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_SBIX));
}

bool FT_HAS_SBIX_OVERLAY(FT_Face face) { 
    return (!!(face.face_flags & FT_FACE_FLAG_SBIX_OVERLAY));
}


enum FT_STYLE_FLAG_ITALIC =  ( 1 << 0 );
enum FT_STYLE_FLAG_BOLD =    ( 1 << 1 );

struct FT_Size_InternalRec;
alias FT_Size_Internal = FT_Size_InternalRec*;

struct  FT_Size_Metrics {
    FT_UShort  x_ppem;      /* horizontal pixels per EM               */
    FT_UShort  y_ppem;      /* vertical pixels per EM                 */

    FT_Fixed   x_scale;     /* scaling values used to convert font    */
    FT_Fixed   y_scale;     /* units to 26.6 fractional pixels        */

    FT_Pos     ascender;    /* ascender in 26.6 frac. pixels          */
    FT_Pos     descender;   /* descender in 26.6 frac. pixels         */
    FT_Pos     height;      /* text height in 26.6 frac. pixels       */
    FT_Pos     max_advance; /* max horizontal advance, in 26.6 pixels */
}

alias struct  FT_SizeRec_
{
    FT_Face           face;      /* parent face object              */
    FT_Generic        generic;   /* generic pointer for client uses */
    FT_Size_Metrics   metrics;   /* size metrics                    */
    FT_Size_Internal  internal;
}

struct FT_SubGlyphRec;
alias FT_SubGlyph = FT_SubGlyphRec*;

struct FT_Slot_InternalRec;
alias FT_Slot_Internal = FT_Slot_InternalRec*;

struct FT_GlyphSlotRec {
    FT_Library        library;
    FT_Face           face;
    FT_GlyphSlot      next;
    FT_UInt           glyph_index; /* new in 2.10; was reserved previously */
    FT_Generic        generic;

    FT_Glyph_Metrics  metrics;
    FT_Fixed          linearHoriAdvance;
    FT_Fixed          linearVertAdvance;
    FT_Vector         advance;

    FT_Glyph_Format   format;

    FT_Bitmap         bitmap;
    FT_Int            bitmap_left;
    FT_Int            bitmap_top;

    FT_Outline        outline;

    FT_UInt           num_subglyphs;
    FT_SubGlyph       subglyphs;

    void*             control_data;
    long              control_len;

    FT_Pos            lsb_delta;
    FT_Pos            rsb_delta;

    void*             other;

    FT_Slot_Internal  internal;
}

FT_Error FT_Init_FreeType(FT_Library  *alibrary);
FT_Error FT_Done_FreeType( FT_Library  library );

enum FT_OPEN_MEMORY =    0x1;
enum FT_OPEN_STREAM =    0x2;
enum FT_OPEN_PATHNAME =  0x4;
enum FT_OPEN_DRIVER =    0x8;
enum FT_OPEN_PARAMS =    0x10;

struct FT_Parameter {
    FT_ULong    tag;
    FT_Pointer  data;

}

struct FT_Open_Args {
    FT_UInt         flags;
    const(FT_Byte)*  memory_base;
    FT_Long         memory_size;
    FT_String*      pathname;
    FT_Stream       stream;
    FT_Module       driver;
    FT_Int          num_params;
    FT_Parameter*   params;
}

FT_Error FT_New_Face( FT_Library   library,
            const char*  filepathname,
            FT_Long      face_index,
            FT_Face     *aface );

FT_Error FT_New_Memory_Face( FT_Library      library,
                    const FT_Byte*  file_base,
                    FT_Long         file_size,
                    FT_Long         face_index,
                    FT_Face        *aface );

FT_Error FT_Open_Face( FT_Library           library,
            const FT_Open_Args*  args,
            FT_Long              face_index,
            FT_Face             *aface );

FT_Error FT_Attach_File( FT_Face      face,
                const char*  filepathname );

FT_Error FT_Attach_Stream( FT_Face              face,
                const FT_Open_Args*  parameters );

FT_Error FT_Reference_Face( FT_Face  face );

FT_Error FT_Done_Face( FT_Face  face );

FT_Error FT_Select_Size( FT_Face  face,
                FT_Int   strike_index );

enum FT_Size_Request_Type {
    FT_SIZE_REQUEST_TYPE_NOMINAL,
    FT_SIZE_REQUEST_TYPE_REAL_DIM,
    FT_SIZE_REQUEST_TYPE_BBOX,
    FT_SIZE_REQUEST_TYPE_CELL,
    FT_SIZE_REQUEST_TYPE_SCALES,

    FT_SIZE_REQUEST_TYPE_MAX
}

struct  FT_Size_RequestRec {
    FT_Size_Request_Type  type;
    FT_Long               width;
    FT_Long               height;
    FT_UInt               horiResolution;
    FT_UInt               vertResolution;
}

FT_Error FT_Request_Size( FT_Face          face,
                FT_Size_Request  req );

FT_Error FT_Set_Char_Size( FT_Face     face,
                FT_F26Dot6  char_width,
                FT_F26Dot6  char_height,
                FT_UInt     horz_resolution,
                FT_UInt     vert_resolution );

FT_Error FT_Set_Pixel_Sizes( FT_Face  face,
                    FT_UInt  pixel_width,
                    FT_UInt  pixel_height );

FT_Error FT_Load_Glyph( FT_Face   face,
                FT_UInt   glyph_index,
                FT_Int  load_flags );

FT_Error FT_Load_Char( FT_Face   face,
            FT_ULong  char_code,
            FT_Int  load_flags );

enum FT_LOAD_DEFAULT =                      0x0;
enum FT_LOAD_NO_SCALE =                     ( 1L << 0  );
enum FT_LOAD_NO_HINTING =                   ( 1L << 1  );
enum FT_LOAD_RENDER =                       ( 1L << 2  );
enum FT_LOAD_NO_BITMAP =                    ( 1L << 3  );
enum FT_LOAD_VERTICAL_LAYOUT =              ( 1L << 4  );
enum FT_LOAD_FORCE_AUTOHINT =               ( 1L << 5  );
enum FT_LOAD_CROP_BITMAP =                  ( 1L << 6  );
enum FT_LOAD_PEDANTIC =                     ( 1L << 7  );
enum FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH =  ( 1L << 9  );
enum FT_LOAD_NO_RECURSE =                   ( 1L << 10 );
enum FT_LOAD_IGNORE_TRANSFORM =             ( 1L << 11 );
enum FT_LOAD_MONOCHROME =                   ( 1L << 12 );
enum FT_LOAD_LINEAR_DESIGN =                ( 1L << 13 );
enum FT_LOAD_SBITS_ONLY =                   ( 1L << 14 );
enum FT_LOAD_NO_AUTOHINT =                  ( 1L << 15 );
enum FT_LOAD_COLOR =                        ( 1L << 20 );
enum FT_LOAD_COMPUTE_METRICS =              ( 1L << 21 );
enum FT_LOAD_BITMAP_METRICS_ONLY =          ( 1L << 22 );
enum FT_LOAD_NO_SVG =                       ( 1L << 24 );
enum FT_LOAD_ADVANCE_ONLY =                 ( 1L << 8  );
enum FT_LOAD_SVG_ONLY =                     ( 1L << 23 );

enum FT_LOAD_TARGET_(int x) =   (cast(FT_Int)((x) & 15) << 16);
enum FT_LOAD_TARGET_NORMAL =  FT_LOAD_TARGET_!(FT_RENDER_MODE_NORMAL);
enum FT_LOAD_TARGET_LIGHT =   FT_LOAD_TARGET_!(FT_RENDER_MODE_LIGHT);
enum FT_LOAD_TARGET_MONO =    FT_LOAD_TARGET_!(FT_RENDER_MODE_MONO);
enum FT_LOAD_TARGET_LCD =     FT_LOAD_TARGET_!(FT_RENDER_MODE_LCD);
enum FT_LOAD_TARGET_LCD_V =   FT_LOAD_TARGET_!(FT_RENDER_MODE_LCD_V);
enum FT_LOAD_TARGET_MODE(int x) = (cast(FT_Int)((x) >> 16) & 15);

void FT_Set_Transform( FT_Face     face,
                FT_Matrix*  matrix,
                FT_Vector*  delta );

void FT_Get_Transform( FT_Face     face,
                FT_Matrix*  matrix,
                FT_Vector*  delta );

alias FT_Render_Mode = uint;
enum FT_Render_Mode
    FT_RENDER_MODE_NORMAL = 0,
    FT_RENDER_MODE_LIGHT = 1,
    FT_RENDER_MODE_MONO = 2,
    FT_RENDER_MODE_LCD = 3,
    FT_RENDER_MODE_LCD_V = 4,
    FT_RENDER_MODE_SDF = 5,
    FT_RENDER_MODE_MAX = 6;

FT_Error FT_Render_Glyph( FT_GlyphSlot    slot,
                FT_Render_Mode  render_mode );

enum FT_Kerning_Mode {
    FT_KERNING_DEFAULT = 0,
    FT_KERNING_UNFITTED,
    FT_KERNING_UNSCALED
}

FT_Error FT_Get_Kerning( FT_Face     face,
                FT_UInt     left_glyph,
                FT_UInt     right_glyph,
                FT_UInt     kern_mode,
                FT_Vector  *akerning );

FT_Error FT_Get_Track_Kerning( FT_Face    face,
                    FT_Fixed   point_size,
                    FT_Int     degree,
                    FT_Fixed*  akerning );

FT_Error FT_Select_Charmap( FT_Face      face,
                    FT_Encoding  encoding );


/**************************************************************************
*
* @function:
*   FT_Set_Charmap
*
* @description:
*   Select a given charmap for character code to glyph index mapping.
*
* @inout:
*   face ::
*     A handle to the source face object.
*
* @input:
*   charmap ::
*     A handle to the selected charmap.
*
* @return:
*   FreeType error code.  0~means success.
*
* @note:
*   This function returns an error if the charmap is not part of the face
*   (i.e., if it is not listed in the `face->charmaps` table).
*
*   It also fails if an OpenType type~14 charmap is selected (which
*   doesn't map character codes to glyph indices at all).
*/
FT_Error FT_Set_Charmap( FT_Face     face,
                FT_CharMap  charmap );

FT_Int FT_Get_Charmap_Index( FT_CharMap  charmap );

FT_UInt FT_Get_Char_Index( FT_Face   face,
                    FT_ULong  charcode );

FT_ULong FT_Get_First_Char( FT_Face   face,
                    FT_UInt  *agindex );

FT_ULong FT_Get_Next_Char( FT_Face    face,
                FT_ULong   char_code,
                FT_UInt   *agindex );

FT_Error FT_Face_Properties( FT_Face        face,
                    FT_UInt        num_properties,
                    FT_Parameter*  properties );

FT_UInt FT_Get_Name_Index( FT_Face           face,
                    const FT_String*  glyph_name );

FT_Error FT_Get_Glyph_Name( FT_Face     face,
                    FT_UInt     glyph_index,
                    FT_Pointer  buffer,
                    FT_UInt     buffer_max );

const(char)* FT_Get_Postscript_Name( FT_Face  face );

enum FT_SUBGLYPH_FLAG_ARGS_ARE_WORDS =          1;
enum FT_SUBGLYPH_FLAG_ARGS_ARE_XY_VALUES =      2;
enum FT_SUBGLYPH_FLAG_ROUND_XY_TO_GRID =        4;
enum FT_SUBGLYPH_FLAG_SCALE =                   8;
enum FT_SUBGLYPH_FLAG_XY_SCALE =             0x40;
enum FT_SUBGLYPH_FLAG_2X2 =                  0x80;
enum FT_SUBGLYPH_FLAG_USE_MY_METRICS =      0x200;

FT_Error FT_Get_SubGlyph_Info( FT_GlyphSlot  glyph,
                    FT_UInt       sub_index,
                    FT_Int       *p_index,
                    FT_UInt      *p_flags,
                    FT_Int       *p_arg1,
                    FT_Int       *p_arg2,
                    FT_Matrix    *p_transform );

enum FT_FSTYPE_INSTALLABLE_EMBEDDING =         0x0000;
enum FT_FSTYPE_RESTRICTED_LICENSE_EMBEDDING =  0x0002;
enum FT_FSTYPE_PREVIEW_AND_PRINT_EMBEDDING =   0x0004;
enum FT_FSTYPE_EDITABLE_EMBEDDING =            0x0008;
enum FT_FSTYPE_NO_SUBSETTING =                 0x0100;
enum FT_FSTYPE_BITMAP_EMBEDDING_ONLY =         0x0200;

FT_UShort FT_Get_FSType_Flags( FT_Face  face );

FT_UInt FT_Face_GetCharVariantIndex( FT_Face   face,
                            FT_ULong  charcode,
                            FT_ULong  variantSelector );

FT_Int FT_Face_GetCharVariantIsDefault( FT_Face   face,
                                FT_ULong  charcode,
                                FT_ULong  variantSelector );

FT_UInt* FT_Face_GetVariantSelectors( FT_Face  face );

FT_UInt* FT_Face_GetVariantsOfChar( FT_Face   face,
                            FT_ULong  charcode );

FT_UInt* FT_Face_GetCharsOfVariant( FT_Face   face,
                            FT_ULong  variantSelector );

FT_Long FT_MulDiv( FT_Long  a,
            FT_Long  b,
            FT_Long  c );

FT_Long FT_MulFix( FT_Long  a,
            FT_Long  b );

FT_Long FT_DivFix( FT_Long  a,
            FT_Long  b );

FT_Fixed FT_RoundFix( FT_Fixed  a );

FT_Fixed FT_CeilFix( FT_Fixed  a );

FT_Fixed FT_FloorFix( FT_Fixed  a );

void FT_Vector_Transform(FT_Vector* vector, const(FT_Matrix)* matrix );

enum FREETYPE_MAJOR =  2;
enum FREETYPE_MINOR =  13;
enum FREETYPE_PATCH =  3;

void FT_Library_Version( FT_Library   library,
                    FT_Int      *amajor,
                    FT_Int      *aminor,
                    FT_Int      *apatch );

FT_Bool FT_Face_CheckTrueTypePatents( FT_Face  face );

FT_Bool FT_Face_SetUnpatentedHinting( FT_Face  face, FT_Bool  value );
