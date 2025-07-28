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
import hairetsu.font.collection;
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
void ha_retain(void* obj) @nogc {
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
void* ha_release(void* obj) @nogc {
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
ha_fontfile_t* ha_fontfile_from_memory(ubyte* data, uint length) @nogc {
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
ha_fontfile_t* ha_fontfile_from_memory_with_name(ubyte* data, uint length, const(char)* name) @nogc {
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
ha_fontfile_t* ha_fontfile_from_file(const(char)* path) @nogc {
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
const(char)* ha_fontfile_get_type(ha_fontfile_t* obj) @nogc {
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
const(char)* ha_fontfile_get_name(ha_fontfile_t* obj) @nogc {
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
uint ha_fontfile_get_fonts(ha_fontfile_t* obj, ha_font_t** target) @nogc {
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
const(char)* ha_font_get_name(ha_font_t* obj) @nogc {
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
const(char)* ha_font_get_family(ha_font_t* obj) @nogc {
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
const(char)* ha_font_get_subfamily(ha_font_t* obj) @nogc {
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
const(char)* ha_font_get_type(ha_font_t* obj) @nogc {
    return (cast(Font)obj).type.ptr;
}

/**
    Gets amount of glyphs stored within the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font.
*/
uint ha_font_get_glyph_count(ha_font_t* obj) @nogc {
    return cast(uint)(cast(Font)obj).glyphCount;
}

/**
    Gets Units per EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
uint ha_font_get_upem(ha_font_t* obj) @nogc {
    return (cast(Font)obj).upem;
}

/**
    Gets lowest recommended pixels-per-EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The lowest recommended pixels-per-EM for readability.
*/
uint ha_font_get_lowest_ppem(ha_font_t* obj) @nogc {
    return (cast(Font)obj).lowestPPEM;
}

/**
    Gets the global metrics of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The global metrics.
*/
FontMetrics ha_font_get_global_metrics(ha_font_t* obj) @nogc {
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
uint ha_font_find_glyph(ha_font_t* obj, uint codepoint) @nogc {
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
GlyphMetrics ha_font_glyph_metrics_for(ha_font_t* obj, uint glyphId) @nogc {
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
ha_face_t* ha_font_create_face(ha_font_t* obj) @nogc {
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
uint ha_face_get_upem(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).upem;
}

/**
    Gets scale of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scale factor.
*/
float ha_face_get_scale(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).scale;
}

/**
    Gets pixels-per-EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The pixels-per-EM.
*/
float ha_face_get_ppem(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).ppem;
}

/**
    Gets amount of glyphs stored within the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font face.
*/
uint ha_face_get_glyph_count(ha_face_t* obj) @nogc {
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
ha_face_t* ha_face_get_fallback(ha_face_t* obj) @nogc {
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
void ha_face_set_fallback(ha_face_t* obj, ha_face_t* face) @nogc {
    (cast(FontFace)obj).fallback = cast(FontFace)face;
}

/**
    Gets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
    
    Returns:
        Whether hinting is requested.
*/
bool ha_face_get_hinting(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).wantHinting;
}

/**
    Sets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_hinting(ha_face_t* obj, bool value) @nogc {
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
float ha_face_get_dpi(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).dpi;
}

/**
    Sets the dots-per-inch of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_dpi(ha_face_t* obj, float value) @nogc {
    (cast(FontFace)obj).dpi = value;
}

/**
    Gets the point size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_pt(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).pt;
}

/**
    Sets the point size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_pt(ha_face_t* obj, float value) @nogc {
    (cast(FontFace)obj).pt = value;
}

/**
    Gets the pixel size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_px(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).px;
}

/**
    Sets the pixel size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_px(ha_face_t* obj, float value) @nogc {
    (cast(FontFace)obj).px = value;
}

/**
    Gets the scaled global metrics of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scaled global metrics.
*/
FontMetrics ha_face_get_global_metrics(ha_face_t* obj) @nogc {
    return (cast(FontFace)obj).faceMetrics;
}

/**
    Gets a glyph from a glyph ID.

    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to fetch.
        type = The type of glyph data to fetch for the glyph.
*/
ha_glyph_t* ha_face_get_glyph(ha_face_t* obj, uint glyphId, GlyphType type) @nogc {
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
void ha_glyph_free(ha_glyph_t* obj) @nogc {
    nu_free(obj);
}

/**
    Gets the metrics for the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The metrics of the glyph.
*/
GlyphMetrics ha_glyph_get_metrics(ha_glyph_t* obj) @nogc {
    return (cast(Glyph*)obj).metrics;
}

/**
    Gets the ID of the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The ID of the glyph.
*/
uint ha_glyph_get_id(ha_glyph_t* obj) @nogc {
    return (cast(Glyph*)obj).id;
}

/**
    Gets the type of data associated with the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The type of the data associated with the glyph.
*/
GlyphType ha_glyph_get_type(ha_glyph_t* obj) @nogc {
    return (cast(Glyph*)obj).rawData.type;
}

/**
    Gets whether the glyph has any data associated with it.
    
    Params:
        obj = The object to query.
    
    Returns:
        True if the glyph has data.
*/
bool ha_glyph_get_has_data(ha_glyph_t* obj) @nogc {
    return (cast(Glyph*)obj).hasData;
}

/**
    Gets the SVG data associated with the glyph (if any)
    
    Params:
        obj = The object to query.
        length = Where to store the length of the data.
    
    Returns:
        A pointer to the internal storage for the SVG body.

    Note:
        The SVG data is owned by the parent font, you should
        NOT free the SVG data. The data is encoded in UTF-8.
        If no SVG is associated with the glyph, $(D null) is 
        returned and $(D length) is set to $(D 0). 
*/
const(char)* ha_glyph_get_svg(ha_glyph_t* obj, uint* length) @nogc {
    *length = cast(uint)(cast(Glyph*)obj).svg.length;
    return (cast(Glyph*)obj).svg.ptr;
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
void ha_glyph_rasterize(ha_glyph_t* obj, ubyte** data, uint* length, uint* width, uint* height) @nogc {
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
void ha_glyph_rasterize_aliased(ha_glyph_t* obj, ubyte** data, uint* length, uint* width, uint* height) @nogc {
    HaBitmap bmp = (cast(Glyph*)obj).rasterize(false);
    *data = bmp.data.ptr;
    *length = cast(uint)bmp.data.length;
    *width = bmp.width;
    *height = bmp.height;
}

//
//      COLLECTIONS
//

/**
    Opaque handle to a Font Collection
*/
struct ha_collection_t;

/**
    Opaque handle to a Font Family
*/
struct ha_family_t;

/**
    Opaque handle to a Font Info
*/
struct ha_info_t;

/**
    Indexes the system to create a font collection.

    Params:
        update = Whether to update the font cache.
    
    Returns:
        A new font collection on success,
        $(D null) on failure.
*/
ha_collection_t* ha_collection_create_from_system(bool update) @nogc {
    return cast(ha_collection_t*)FontCollection.createFromSystem(update);
}

/**
    Creates an empty font collection.

    Returns:
        A new font collection on success,
        $(D null) on failure.
*/
ha_collection_t* ha_collection_create() @nogc {
    
    import numem : nogc_new;
    return cast(ha_collection_t*)nogc_new!FontCollection();
}

/**
    Gets the amount of font families loaded for a collection.

    Params:
        obj = The object to query
    
    Returns:
        The amount of families in the collection.
*/
uint ha_collection_get_family_count(ha_collection_t* obj) @nogc {
    return cast(uint)(cast(FontCollection)obj).families.length;
}

/**
    Gets the loaded families for the collection

    Params:
        obj = The object to query
    
    Returns:
        An array of font families owned by the collection.

    Note:
        The families array is owned by the collection, you must 
        NOT free it.
*/
ha_family_t** ha_collection_get_families(ha_collection_t* obj) @nogc {
    return cast(ha_family_t**)(cast(FontCollection)obj).families.ptr;
}

/**
    Adds a font family to the font collection.

    Params:
        obj = The object to query
        family = The family to add
    
    Returns:
        An array of font families owned by the collection.

    Note:
        The families array is owned by the collection, you must 
        NOT free it.
*/
void ha_collection_add_family(ha_collection_t* obj, ha_family_t* family) @nogc {
    (cast(FontCollection)obj).addFamily(cast(FontFamily)family);
}

/**
    Gets the name of a font family.

    Params:
        obj = The object to query
    
    Returns:
        The anme of the font family.
*/
const(char)* ha_family_get_name(ha_family_t* obj) @nogc {
    return (cast(FontFamily)obj).familyName.ptr;
}

/**
    Gets the amount of faces within the family.

    Params:
        obj = The object to query
    
    Returns:
        The amount of faces in the family.
*/
uint ha_family_get_face_info_count(ha_family_t* obj) @nogc {
    return cast(uint)(cast(FontFamily)obj).faces.length;
}

/**
    Gets the faces within the family.

    Params:
        obj = The object to query
    
    Returns:
        An array of font face descriptions owned by the family.

    Note:
        The faces array is owned by the family, you must 
        NOT free it.
*/
ha_info_t** ha_family_get_face_infos(ha_family_t* obj) @nogc {
    return cast(ha_info_t**)(cast(FontFamily)obj).faces.ptr;
}

/**
    Gets whether a font family contains a face that supports
    the given Unicode character code point.

    Params:
        obj = The object to query
        character = The unicode character to query
    
    Returns:
        $(D true) if the family has the given character,
        $(D false) otherwise.
*/
bool ha_family_has_character(ha_family_t* obj, uint character) @nogc {
    return (cast(FontFamily)obj).hasCharacter(character);
}

/**
    Gets the first face descriptor that supports a given character.

    Params:
        obj = The object to query
        character = The unicode character to query
    
    Returns:
        A $(D ha_info_t*) descriptor on success,
        $(D null) otherwise.
*/
ha_info_t* ha_family_get_first_with(ha_family_t* obj, uint character) @nogc {
    return cast(ha_info_t*)(cast(FontFamily)obj).getFirstFaceWith(character);
}

/**
    Gets the first face descriptor that supports a given character.

    Params:
        obj = The object to query
        info = The face descriptor to add.
*/
void ha_family_add_face_info(ha_family_t* obj, ha_info_t* info) @nogc {
    (cast(FontFamily)obj).addFace(cast(FontFaceInfo)info);
}

/**
    Gets the file path of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_path(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).path.ptr;
}

/**
    Gets the name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_name(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).name.ptr;
}

/**
    Gets the postscript name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_postscript_name(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).postscriptName.ptr;
}

/**
    Gets the family name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_family_name(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).familyName.ptr;
}

/**
    Gets the sub-family name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_subfamily_name(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).subfamilyName.ptr;
}

/**
    Gets the sample text of the font face described by
    the descriptor.

    Params:
        obj = The object to query
    
    Returns:
        The sample text of the font.

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
const(char)* ha_info_get_sample_text(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).sampleText.ptr;
}

/**
    Gets the type of outlines the font face described by
    the descriptor contains.

    Params:
        obj = The object to query
    
    Returns:
        The type of outlines the font supports.
*/
GlyphType ha_info_get_outline_type(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).outlines;
}

/**
    Gets whether the font face described by
    the descriptor is a variable font.

    Params:
        obj = The object to query
    
    Returns:
        $(D true) if the font is variable,
        $(D false) otherwise.
*/
bool ha_info_get_is_variable(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).variable;
}

/**
    Gets whether the font face described by
    the descriptor can be realized to a Hairetsu
    font face object.

    Params:
        obj = The object to query
    
    Returns:
        $(D true) if the font can be realized,
        $(D false) otherwise.
*/
bool ha_info_get_is_realizable(ha_info_t* obj) @nogc {
    return (cast(FontFaceInfo)obj).isRealizable;
}

/**
    Gets whether the font face described by the descriptor
    supports the given Unicode character code point.

    Params:
        obj = The object to query
        character = The unicode character to query
    
    Returns:
        $(D true) if the face has the given character,
        $(D false) otherwise.
*/
bool ha_info_get_has_character(ha_info_t* obj, uint character) @nogc {
    return (cast(FontFaceInfo)obj).hasCharacter(character);
}

/**
    Realises the font face into a usable font object.

    Returns:
        A font created from the font info.
*/
ha_font_t* ha_info_realize(ha_info_t* obj) @nogc {
    return cast(ha_font_t*)(cast(FontFaceInfo)obj).realize();
}
