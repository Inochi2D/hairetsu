/**
    Hairetsu C FFI Interface.

    This generally should not be used by code written in D and is mainly provided
    to allow using the library from other languages.

    All base objects exposed by hairetsu are reference counted and **MUST** be managed
    with the provided $(D ha_retain) and $(D ha_release) methods.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.cffi;
import hairetsu.font.file;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.font.cmap;
import hairetsu.font.glyph;
import hairetsu.common;

// Extern deps used internally.
import nulib.string;
import numem : NuRefCounted;
import numem.core.hooks : nu_free;

extern(C) export:

//
//      LIBRARY INITIALIZATION.
//

/**
    Gets whether hairetsu is initialized.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
bool ha_get_initialized() @nogc nothrow {
    import hairetsu : haIsInitialized;
    return haIsInitialized();
}

/**
    Attempts to initialize hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
bool ha_try_initialize() @nogc {
    import hairetsu : haTryInitialize;
    return haTryInitialize();
}

/**
    Attempts to shut down hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
void ha_try_shutdown() @nogc {
    import hairetsu : haTryShutdown;
    return haTryShutdown();
}

//
//      MEMORY MANAGMENT.
//

/**
    Retains a reference to a hairetsu object.

    Params:
        obj = The object to retain.
*/
void ha_retain(void* obj) {
    (cast(NuRefCounted)obj).retain();
}

/**
    Releases a reference to a hairetsu object.

    Params:
        obj = The object to retain.
    
    Returns:
        The resulting handle after the operation,
        $(D null) if the object was freed.
*/
void* ha_release(void* obj) {
    return cast(void*)(cast(NuRefCounted)obj).release();
}


//
//      FONT FILES.
//


/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_fontfile_t;

/**
    Creates a new font for the given memory slice

    Params:
        data =  The memory slice to read the font data from.
        length = The lengty of the memory slice to read the data from.
    
    Returns:
        A $(D ha_fontfile_t*) instance on success,
        $(D null) on failure.
    
    Note:
        This function will copy the memory out of data,
        this is to ensure ownership of the data is properly handled.
*/
ha_fontfile_t* ha_fontfile_from_memory(ubyte* data, uint length) {
    return cast(ha_fontfile_t*)FontFile.fromMemory(data[0..length]);
}

/**
    Creates a new font for the given memory slice with a given name.

    Params:
        data =  The memory slice to read the font data from.
        length = The lengty of the memory slice to read the data from.
        name = The name to give the memory sliced font.
    
    Returns:
        A $(D ha_fontfile_t*) instance on success,
        $(D null) on failure.
    
    Note:
        This function will copy the memory out of data,
        this is to ensure ownership of the data is properly handled.
*/
ha_fontfile_t* ha_fontfile_from_memory_with_name(ubyte* data, uint length, const(char)* name) {
    nstring nname = name;
    return cast(ha_fontfile_t*)FontFile.fromMemory(data[0..length], nname);
}

/**
    Creates a new font for the given file path

    Params:
        path =  Path to the file containing the font, in
        null-terminate UTF8 encoding.
    
    Returns:
        A $(D FontFile) instance on success,
        $(D null) on failure.
*/
ha_fontfile_t* ha_fontfile_from_file(const(char)* path) {
    nstring npath = path;
    return cast(ha_fontfile_t*)FontFile.fromFile(npath);
}

/**
    Gets the type name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of the type of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
const(char)* ha_fontfile_get_type(ha_fontfile_t* obj) {
    if (!obj)
        return null;
    
    return (cast(FontFile)obj).type.ptr;
}

/**
    Gets the name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
const(char)* ha_fontfile_get_name(ha_fontfile_t* obj) {
    if (!obj)
        return null;
    
    return (cast(FontFile)obj).name.ptr;
}

/**
    Gets the list of fonts within the file.

    Params:
        obj = The object to query.
        target = Where to store the array.

    Returns:
        Unsigned 32-bit integer length of the font objects
        owned by the font file; the returned array should
        NOT be freed by the caller.
*/
uint ha_fontfile_get_fonts(ha_fontfile_t* obj, ha_font_t** target) {
    *target = cast(ha_font_t*)((cast(FontFile)obj).fonts.ptr);
    return cast(uint)(cast(FontFile)obj).fonts.length;
}


//
//      FONT OBJECTS
//


/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_font_t;

/**
    Gets the postscript name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The postscript name in UTF-8 format.

    Note:
        The string is owned by the font and should not be
        freed by you directly.
*/
const(char)* ha_font_get_name(ha_font_t* obj) {
    return (cast(Font)obj).name.ptr;
}

/**
    Gets the family name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The family name in UTF-8 format.

    Note:
        The string is owned by the font and should not be
        freed by you directly.
*/
const(char)* ha_font_get_family(ha_font_t* obj) {
    return (cast(Font)obj).family.ptr;
}

/**
    Gets the subfamily name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The subfamily name in UTF-8 format.

    Note:
        The string is owned by the font and should not be
        freed by you directly.
*/
const(char)* ha_font_get_subfamily(ha_font_t* obj) {
    return (cast(Font)obj).subfamily.ptr;
}

/**
    Gets the type name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The type name in UTF-8 format.

    Note:
        The string is owned by the font and should not be
        freed by you directly.
*/
const(char)* ha_font_get_type(ha_font_t* obj) {
    return (cast(Font)obj).type.ptr;
}

/**
    Gets amount of glyphs stored within the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font.
*/
uint ha_font_get_glyph_count(ha_font_t* obj) {
    return cast(uint)(cast(Font)obj).glyphCount;
}

/**
    Gets Units per EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
uint ha_font_get_upem(ha_font_t* obj) {
    return (cast(Font)obj).upem;
}

/**
    Gets lowest recommended pixels-per-EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The lowest recommended pixels-per-EM for readability.
*/
uint ha_font_get_lowest_ppem(ha_font_t* obj) {
    return (cast(Font)obj).lowestPPEM;
}

/**
    Gets the global metrics of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The global metrics.
*/
FontMetrics ha_font_get_global_metrics(ha_font_t* obj) {
    return (cast(Font)obj).fontMetrics;   
}

/**
    Gets the base ID of a glyph within the font associated
    with the given code point.
    
    Params:
        obj = The object to query.
        codepoint = The Unicode code point of the glyph.
    
    Returns:
        The glyph ID for the given codepoint, or 
        $(D GLYPH_MISSING) if not found.
*/
uint ha_font_find_glyph(ha_font_t* obj, uint codepoint) {
    return (cast(Font)obj).charMap.getGlyphIndex(codepoint);
}

/**
    Gets the metrics for the given glyph ID.
    
    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to query.
    
    Returns:
        The base metrics of the given glyph.
*/
GlyphMetrics ha_font_glyph_metrics_for(ha_font_t* obj, uint glyphId) {
    return (cast(Font)obj).getMetricsFor(glyphId);
}

/**
    Creates a new face object from the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        A reference to a newly created face object,
        or $(D null) on failure.
*/
ha_face_t* ha_font_create_face(ha_font_t* obj) {
    return cast(ha_face_t*)((cast(Font)obj).createFace());
}


//
//      FACE OBJECTS
//

/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_face_t;

/**
    Gets Units per EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
uint ha_face_get_upem(ha_face_t* obj) {
    return (cast(FontFace)obj).upem;
}

/**
    Gets scale of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scale factor.
*/
float ha_face_get_scale(ha_face_t* obj) {
    return (cast(FontFace)obj).scale;
}

/**
    Gets pixels-per-EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The pixels-per-EM.
*/
float ha_face_get_ppem(ha_face_t* obj) {
    return (cast(FontFace)obj).ppem;
}

/**
    Gets amount of glyphs stored within the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font face.
*/
uint ha_face_get_glyph_count(ha_face_t* obj) {
    return (cast(FontFace)obj).glyphCount;
}

/**
    Gets the face which is used when the given face does not
    contain a glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        A weak reference to the fallback face, or
        $(D null) if no fallback is specified.
*/
ha_face_t* ha_face_get_fallback(ha_face_t* obj) {
    return cast(ha_face_t*)(cast(FontFace)obj).fallback;
}

/**
    Sets the face which is used when the given face does not
    contain a glyph. The face can belong to a different font.
    
    Params:
        obj = The object to query.
        face = The face to use as a fallback.
    
    Note:
        The face may not create an infinite self-referential chain.
        If this is the case the operation will set the fallback to
        $(D null)!
*/
void ha_face_set_fallback(ha_face_t* obj, ha_face_t* face) {
    (cast(FontFace)obj).fallback = cast(FontFace)face;
}

/**
    Gets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
    
    Returns:
        Whether hinting is requested.
*/
bool ha_face_get_hinting(ha_face_t* obj) {
    return (cast(FontFace)obj).wantHinting;
}

/**
    Sets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_hinting(ha_face_t* obj, bool value) {
    (cast(FontFace)obj).wantHinting = value;
}

/**
    Gets the dots-per-inch of the font face, defaults to 96.

    By default this value is 96, to comply with the reference CSS DPI,
    if you're rendering to paper or the display has DPI information,
    this value needs to be changed.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set DPI.
*/
float ha_face_get_dpi(ha_face_t* obj) {
    return (cast(FontFace)obj).dpi;
}

/**
    Sets the dots-per-inch of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_dpi(ha_face_t* obj, float value) {
    (cast(FontFace)obj).dpi = value;
}

/**
    Gets the point size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_pt(ha_face_t* obj) {
    return (cast(FontFace)obj).pt;
}

/**
    Sets the point size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_pt(ha_face_t* obj, float value) {
    (cast(FontFace)obj).pt = value;
}

/**
    Gets the pixel size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_px(ha_face_t* obj) {
    return (cast(FontFace)obj).px;
}

/**
    Sets the pixel size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_px(ha_face_t* obj, float value) {
    (cast(FontFace)obj).px = value;
}

/**
    Gets the scaled global metrics of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scaled global metrics.
*/
FontMetrics ha_face_get_global_metrics(ha_face_t* obj) {
    return (cast(FontFace)obj).faceMetrics;
}

/**
    Gets a glyph from a glyph ID.

    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to fetch.
        type = The type of glyph data to fetch for the glyph.
*/
ha_glyph_t* ha_face_get_glyph(ha_face_t* obj, uint glyphId, GlyphType type) {
    return cast(ha_glyph_t*)((cast(FontFace)obj).getGlyph(glyphId, type).copyToHeap());
}

//
//      GLYPHS
//

/**
    Glyph types
*/
enum GlyphType 
    HA_GLYPH_TYPE_NONE = GlyphType.none,
    HA_GLYPH_TYPE_SBIX = GlyphType.sbix,
    HA_GLYPH_TYPE_EBDT = GlyphType.ebdt,
    HA_GLYPH_TYPE_CBDT = GlyphType.cbdt,
    HA_GLYPH_TYPE_BITMAP = GlyphType.bitmap,
    HA_GLYPH_TYPE_TTF = GlyphType.trueType,
    HA_GLYPH_TYPE_CFF = GlyphType.cff,
    HA_GLYPH_TYPE_CFF2 = GlyphType.cff2,
    HA_GLYPH_TYPE_OUTLINE = GlyphType.outline,
    HA_GLYPH_TYPE_SVG = GlyphType.svg,
    HA_GLYPH_TYPE_ANY = GlyphType.any;

/**
    Opaque handle to a glyph.
    
    Glyphs must be deallocated with ha_glyph_free after use!
*/
struct ha_glyph_t;

/**
    Frees the given glyph.
*/
void ha_glyph_free(ha_glyph_t* obj) {
    nu_free(obj);
}

/**
    Gets whether the glyph has any data associated with it.
    
    Params:
        obj = The object to query.
    
    Returns:
        True if the glyph has data.
*/
bool ha_glyph_get_has_data(ha_glyph_t* obj) {
    return (cast(Glyph*)obj).hasData;
}

/**
    Gets whether the glyph has any data associated with it.
    
    Params:
        obj = The object to query.
        svg = Where to store the SVG data pointer.
        length = Where to store the length of the data.
    
    Note:
        The SVG data is owned by the parent font, you should
        NOT free the SVG data. The data is encoded in UTF-8.
*/
void ha_glyph_get_svg(ha_glyph_t* obj, const(char)** svg, uint* length) {
    if (!svg) return;

    *svg = (cast(Glyph*)obj).svg.ptr;
    *length = cast(uint)(cast(Glyph*)obj).svg.length;
}

/**
    Tries to rasterize the given glyph to the given buffer.
    
    Params:
        obj = The object to query.
        data = Destination array to store the bitmap reference.
        length = Where to store the length of the bitmap array.
        width = Where to store the width of the bitmap.
        height = Where to store the height of the bitmap.

    Note:
        The rasterized data belongs to you and must be freed by you,
        using standard C $(D free) mechanisms.
*/
void ha_glyph_rasterize(ha_glyph_t* obj, ubyte** data, uint* length, uint* width, uint* height) {
    HaBitmap bmp = (cast(Glyph*)obj).rasterize(true);
    *data = bmp.data.ptr;
    *length = cast(uint)bmp.data.length;
    *width = bmp.width;
    *height = bmp.height;
}

/**
    Tries to rasterize the given glyph to the given buffer;
    rasterization happens without anti-aliasing.
    
    Params:
        obj = The object to query.
        data = Destination array to store the bitmap reference.
        length = Where to store the length of the bitmap array.
        width = Where to store the width of the bitmap.
        height = Where to store the height of the bitmap.

    Note:
        The rasterized data belongs to you and must be freed by you,
        using standard C $(D free) mechanisms.
*/
void ha_glyph_rasterize_aliased(ha_glyph_t* obj, ubyte** data, uint* length, uint* width, uint* height) {
    HaBitmap bmp = (cast(Glyph*)obj).rasterize(false);
    *data = bmp.data.ptr;
    *length = cast(uint)bmp.data.length;
    *width = bmp.width;
    *height = bmp.height;
}
