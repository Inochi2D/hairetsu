/*
    Copyright © 2025, Inochi2D Project
    Distributed under the Boost 1.0 License, see LICENSE file.
    
    Authors:
        Luna Nielsen
*/
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifndef H_HAIRETSU
#define H_HAIRETSU

// Handle calling convention on Windows.
// This will ensure MSVC does not try to use stdcall
// when the D library uses cdecl.
#ifdef _WIN32
    #ifdef _MSC_VER
        #define HA_EXPORT __cdecl
    #else
        #define HA_EXPORT
    #endif
#else
    #define HA_EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

//
//                      MATH TYPES
//
typedef struct vec2 {
    float x;
    float y;
} vec2_t;

typedef struct vec2i {
    int32_t x;
    int32_t y;
} vec2i_t;

typedef struct vec2u {
    int32_t x;
    int32_t y;
} vec2u_t;

typedef struct rect {
    vec2_t min;
    vec2_t max;
} rect_t;

typedef struct recti {
    vec2i_t min;
    vec2i_t max;
} recti_t;

/**
    Metrics shared between glyphs in a font.
*/
typedef struct ha_fontmetrics {

    /**
        The global ascenders for the font.
    */
    vec2_t ascender;
    
    /**
        The global descenders for the font.
    */
    vec2_t descender;
    
    /**
        The global line gaps for the font.
    */
    vec2_t lineGap;
    
    /**
        The global max extents for glyphs.
    */
    vec2_t maxExtent;
    
    /**
        The global max advances for glyphs.
    */
    vec2_t maxAdvance;

    /**
        Minimum start bearing.
    */
    vec2_t minBearingStart;
    
    /**
        Minimum end bearing.
    */
    vec2_t minBearingEnd;
} ha_font_metrics_t;

/**
    Glyph Metrics
*/
typedef struct ha_glyphmetrics {

    /**
        The bounding box of the glyph.
    */
    rect_t bounds;
    
    /**
        The bearing for the glyph.
    */
    vec2_t bearing;
    
    /**
        The advance for the glyph.
    */
    vec2_t advance;

    /**
        The overall scale applied to the glyph.
    */
    float scale;
    
    /**
        Synthetic thickness to apply. (default: 1)
    */
    float thickness;
    
    /**
        Synthetic shear to apply. (default: 1)
    */
    float shear;
} ha_glyph_metrics_t;


typedef uint32_t ha_glyph_type_t;
enum {
    HA_GLYPH_TYPE_NONE      = 0x00,

    // Bitmap glyphs
    HA_GLYPH_TYPE_SBIX      = 0x01,
    HA_GLYPH_TYPE_EDBT      = 0x02,
    HA_GLYPH_TYPE_CBDT      = 0x04,
    HA_GLYPH_TYPE_BITMAP    = HA_GLYPH_TYPE_SBIX | HA_GLYPH_TYPE_EDBT | HA_GLYPH_TYPE_CBDT,
    
    // Outlines
    HA_GLYPH_TYPE_TTF       = 0x10,
    HA_GLYPH_TYPE_CFF       = 0x20,
    HA_GLYPH_TYPE_CFF2      = 0x40,
    HA_GLYPH_TYPE_OUTLINE   = HA_GLYPH_TYPE_TTF | HA_GLYPH_TYPE_CFF | HA_GLYPH_TYPE_CFF2,
    
    // Complex
    HA_GLYPH_TYPE_SVG       = 0x100,
    HA_GLYPH_TYPE_ANY       = HA_GLYPH_TYPE_BITMAP | HA_GLYPH_TYPE_OUTLINE | HA_GLYPH_TYPE_SVG
};

//
//              OPAQUE HANDLES
//
typedef struct ha_fontfile ha_fontfile_t;
typedef struct ha_font ha_font_t;
typedef struct ha_face ha_face_t;
typedef struct ha_glyph ha_glyph_t;
typedef struct ha_glyph ha_collection_t;
typedef struct ha_glyph ha_family_t;
typedef struct ha_glyph ha_info_t;

//
//              LIBRARY INITIALIZATION
//

/**
    Gets whether hairetsu is initialized.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
HA_EXPORT bool ha_get_initialized();

/**
    Attempts to initialize hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
HA_EXPORT bool ha_try_initialize();

/**
    Attempts to shut down hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
HA_EXPORT bool ha_try_shutdown();

//
//              MEMORY MANAGMENT
//

/**
    Retains a reference to a hairetsu object.

    Params:
        obj = The object to retain.
*/
HA_EXPORT void ha_retain(void* obj);

/**
    Releases a reference to a hairetsu object.

    Params:
        obj = The object to retain.
    
    Returns:
        The resulting handle after the operation,
        $(D null) if the object was freed.
*/
HA_EXPORT void* ha_release(void* obj);


//
//              FONT FILES
//

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
HA_EXPORT ha_fontfile_t* ha_fontfile_from_memory(char *data, uint32_t length);

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
HA_EXPORT ha_fontfile_t* ha_fontfile_from_memory_with_name(char *data, uint32_t length, const char *name);

/**
    Creates a new font for the given file path

    Params:
        path =  Path to the file containing the font, in
        null-terminate UTF8 encoding.
    
    Returns:
        A $(D FontFile) instance on success,
        $(D null) on failure.
*/
HA_EXPORT ha_fontfile_t* ha_fontfile_from_file(const char *path);

/**
    Gets the type name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of the type of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
HA_EXPORT const char *ha_fontfile_get_type(ha_fontfile_t *obj);

/**
    Gets the name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
HA_EXPORT const char *ha_fontfile_get_name(ha_fontfile_t *obj);

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
HA_EXPORT uint32_t ha_fontfile_get_fonts(ha_fontfile_t *obj, ha_font_t **target);

//
//              FONT OBJECTS
//

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
HA_EXPORT const char *ha_font_get_name(ha_font_t *obj);

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
HA_EXPORT const char *ha_font_get_family(ha_font_t *obj);

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
HA_EXPORT const char *ha_font_get_subfamily(ha_font_t *obj);

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
HA_EXPORT const char *ha_font_get_type(ha_font_t *obj);

/**
    Gets amount of glyphs stored within the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font.
*/
HA_EXPORT uint32_t ha_font_get_glyph_count(ha_font_t *obj);

/**
    Gets Units per EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
HA_EXPORT uint32_t ha_font_get_upem(ha_font_t *obj);

/**
    Gets lowest recommended pixels-per-EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The lowest recommended pixels-per-EM for readability.
*/
HA_EXPORT uint32_t ha_font_get_lowest_ppem(ha_font_t *obj);

/**
    Gets the global metrics of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The global metrics.
*/
HA_EXPORT ha_font_metrics_t ha_font_get_global_metrics(ha_font_t *obj);

/**
    Gets the metrics for the given glyph ID.
    
    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to query.
    
    Returns:
        The base metrics of the given glyph.
*/
HA_EXPORT ha_glyph_metrics_t ha_font_glyph_metrics_for(ha_font_t *obj, uint32_t glyphId);

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
HA_EXPORT uint32_t ha_font_find_glyph(ha_font_t *obj, uint32_t codepoint);

/**
    Creates a new face object from the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        A reference to a newly created face object,
        or $(D null) on failure.
*/
HA_EXPORT ha_face_t *ha_font_create_face(ha_font_t *obj);

//
//              FACE OBJECTS
//

/**
    Gets Units per EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
HA_EXPORT uint32_t ha_face_get_upem(ha_face_t *obj);

/**
    Gets scale of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scale factor.
*/
HA_EXPORT float ha_face_get_scale(ha_face_t *obj);

/**
    Gets pixels-per-EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The pixels-per-EM.
*/
HA_EXPORT float ha_face_get_ppem(ha_face_t *obj);

/**
    Gets amount of glyphs stored within the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font face.
*/
HA_EXPORT uint32_t ha_face_get_glyph_count(ha_face_t *obj);

/**
    Gets the face which is used when the given face does not
    contain a glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        A weak reference to the fallback face, or
        $(D null) if no fallback is specified.
*/
HA_EXPORT ha_face_t *ha_face_get_fallback(ha_face_t *obj);

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
HA_EXPORT void ha_face_set_fallback(ha_face_t *obj, ha_face_t *face);

/**
    Gets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
    
    Returns:
        Whether hinting is requested.
*/
HA_EXPORT bool ha_face_get_hinting(ha_face_t *obj);

/**
    Sets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
HA_EXPORT void ha_face_set_hinting(ha_face_t *obj, bool value);

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
HA_EXPORT float ha_face_get_dpi(ha_face_t *obj);

/**
    Sets the dots-per-inch of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
HA_EXPORT void ha_face_set_dpi(ha_face_t *obj, float value);

/**
    Gets the point size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
HA_EXPORT float ha_face_get_pt(ha_face_t *obj);

/**
    Sets the point size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
HA_EXPORT void ha_face_set_pt(ha_face_t *obj, float value);

/**
    Gets the pixel size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
HA_EXPORT float ha_face_get_px(ha_face_t *obj);

/**
    Sets the pixel size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
HA_EXPORT void ha_face_set_px(ha_face_t *obj, float value);

/**
    Gets the scaled global metrics of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scaled global metrics.
*/
HA_EXPORT ha_font_metrics_t ha_face_get_global_metrics(ha_face_t *obj);

/**
    Gets a glyph from a glyph ID.

    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to fetch.
        type = The type of glyph data to fetch for the glyph.
*/
HA_EXPORT ha_glyph_t* ha_face_get_glyph(ha_face_t *obj, uint32_t glyphId, ha_glyph_type_t type);

//
//              GLYPHS
//

/**
    Frees the given glyph.
*/
HA_EXPORT void ha_glyph_free(ha_glyph_t *obj);

/**
    Gets the metrics for the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The metrics of the glyph.
*/
HA_EXPORT ha_glyph_metrics_t ha_glyph_get_metrics(ha_glyph_t* obj);

/**
    Gets the ID of the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The ID of the glyph.
*/
HA_EXPORT ha_glyph_type_t ha_glyph_get_type(ha_glyph_t *obj);

/**
    Gets the type of data associated with the glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        The type of the data associated with the glyph.
*/
HA_EXPORT uint32_t ha_glyph_get_id(ha_glyph_t *obj);

/**
    Gets whether the glyph has any data associated with it.
    
    Params:
        obj = The object to query.
    
    Returns:
        True if the glyph has data.
*/
HA_EXPORT bool ha_glyph_get_has_data(ha_glyph_t *obj);

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
HA_EXPORT const char *ha_glyph_get_svg(ha_glyph_t *obj, uint32_t *length);

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
HA_EXPORT void ha_glyph_rasterize(ha_glyph_t *obj, char **data, uint32_t *length, uint32_t *width, uint32_t *height);

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
HA_EXPORT void ha_glyph_rasterize_aliased(ha_glyph_t *obj, char **data, uint32_t *length, uint32_t *width, uint32_t *height);

//
//              COLLECTIONS
//

/**
    Creates an empty font collection.

    Returns:
        A new font collection on success,
        $(D null) on failure.
*/
HA_EXPORT ha_collection_t *ha_collection_create();

/**
    Indexes the system to create a font collection.

    Params:
        update = Whether to update the font cache.
    
    Returns:
        A new font collection on success,
        $(D null) on failure.
*/
HA_EXPORT ha_collection_t *ha_collection_create_from_system(bool update);

/**
    Gets the amount of font families loaded for a collection.

    Params:
        obj = The object to query
    
    Returns:
        The amount of families in the collection.
*/
HA_EXPORT uint32_t ha_collection_get_family_count(ha_collection_t *obj);


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
HA_EXPORT ha_family_t *ha_collection_get_families(ha_collection_t *obj);

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
HA_EXPORT void ha_collection_add_family(ha_collection_t *obj, ha_family_t *family);


/**
    Gets the name of a font family.

    Params:
        obj = The object to query
    
    Returns:
        The anme of the font family.
*/
HA_EXPORT const char *ha_family_get_name(ha_family_t *obj);
/**
    Gets the amount of faces within the family.

    Params:
        obj = The object to query
    
    Returns:
        The amount of faces in the family.
*/
HA_EXPORT uint32_t ha_family_get_face_info_count(ha_family_t *obj);

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
HA_EXPORT ha_info_t *ha_family_get_face_infos(ha_family_t *obj);

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
HA_EXPORT bool ha_family_has_character(ha_family_t *obj, uint32_t character);

/**
    Gets the first face descriptor that supports a given character.

    Params:
        obj = The object to query
        character = The unicode character to query
    
    Returns:
        A $(D ha_info_t*) descriptor on success,
        $(D null) otherwise.
*/
HA_EXPORT ha_info_t* ha_family_get_first_with(ha_family_t *obj, uint32_t character);

/**
    Gets the first face descriptor that supports a given character.

    Params:
        obj = The object to query
        info = The face descriptor to add.
*/
HA_EXPORT void ha_family_add_face_info(ha_family_t *obj, ha_info_t *info);

/**
    Gets the file path of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
HA_EXPORT const char *ha_info_get_path(ha_info_t *obj);

/**
    Gets the name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
HA_EXPORT const char *ha_info_get_name(ha_info_t *obj);

/**
    Gets the postscript name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
HA_EXPORT const char *ha_info_get_postscript_name(ha_info_t *obj);

/**
    Gets the family name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
HA_EXPORT const char *ha_info_get_family_name(ha_info_t *obj);

/**
    Gets the sub-family name of the font face described by
    the descriptor.

    Params:
        obj = The object to query

    Note:
        This memory is owned by the descriptor,
        do not free it.
*/
HA_EXPORT const char *ha_info_get_subfamily_name(ha_info_t *obj);

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
HA_EXPORT const char *ha_info_get_sample_text(ha_info_t *obj);

/**
    Gets the type of outlines the font face described by
    the descriptor contains.

    Params:
        obj = The object to query
    
    Returns:
        The type of outlines the font supports.
*/
HA_EXPORT ha_glyph_type_t ha_info_get_outline_type(ha_info_t *obj);

/**
    Gets whether the font face described by
    the descriptor is a variable font.

    Params:
        obj = The object to query
    
    Returns:
        $(D true) if the font is variable,
        $(D false) otherwise.
*/
HA_EXPORT bool ha_info_get_is_variable(ha_info_t *obj);

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
HA_EXPORT bool ha_info_get_is_realizable(ha_info_t *obj);

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
HA_EXPORT bool ha_info_get_has_character(ha_info_t *obj, uint32_t character);

/**
    Realises the font face into a usable font object.

    Returns:
        A font created from the font info.
*/
HA_EXPORT ha_font_t *ha_info_realize(ha_info_t *obj);

#ifdef __cplusplus
}
#endif

#endif