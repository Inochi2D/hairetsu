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
} vec2i_t;

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
} ha_fontmetrics_t;

/**
    Glyph Metrics
*/
struct ha_glyphmetrics {

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
    float scale = 1;
    
    /**
        Synthetic thickness to apply. (default: 1)
    */
    float thickness = 1;
    
    /**
        Synthetic shear to apply. (default: 1)
    */
    float shear = 0;
} ha_glyphmetrics_t;


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
    HA_GLYPH_TYPE_OUTLINE   = trueType | cff | cff2,
    
    // Complex
    HA_GLYPH_TYPE_SVG       = 0x100,
    HA_GLYPH_TYPE_ANY       = HA_GLYPH_TYPE_BITMAP | HA_GLYPH_TYPE_OUTLINE | HA_GLYPH_TYPE_SVG
}

//
//              OPAQUE HANDLES
//
typedef struct ha_fontfile ha_fontfile_t;
typedef struct ha_font ha_font_t;
typedef struct ha_face ha_face_t;
typedef struct ha_glyph ha_glyph_t;

//
//              MEMORY MANAGMENT
//

/**
    Gets whether hairetsu is initialized.

    Returns:
        true if initialized, false otherwise.
*/
HA_EXPORT bool ha_get_initialized();

/**
    Attempts to initialize hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        true if initialized, false otherwise.
*/
HA_EXPORT bool ha_try_initialize();

/**
    Attempts to shut down hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        true if initialized, false otherwise.
*/
HA_EXPORT bool ha_try_shutdown();

//
//              MEMORY MANAGMENT
//
HA_EXPORT void ha_retain(void* obj);
HA_EXPORT void* ha_release(void* obj);


//
//              FONT FILES
//

HA_EXPORT ha_fontfile_t* ha_fontfile_from_memory(char *data, uint length);
HA_EXPORT ha_fontfile_t* ha_fontfile_from_memory_with_name(ubyte *data, uint length, const char *name);
HA_EXPORT ha_fontfile_t* ha_fontfile_from_file(const char *path);
HA_EXPORT const char *ha_fontfile_get_type(ha_fontfile_t *obj);
HA_EXPORT const char *ha_fontfile_get_name(ha_fontfile_t *obj);
HA_EXPORT uint32_t ha_fontfile_get_fonts(ha_fontfile_t *obj, ha_font_t **target);

//
//              FONT OBJECTS
//

HA_EXPORT const char *ha_font_get_name(ha_font_t *obj);
HA_EXPORT const char *ha_font_get_family(ha_font_t *obj);
HA_EXPORT const char *ha_font_get_subfamily(ha_font_t *obj);
HA_EXPORT const char *ha_font_get_type(ha_font_t *obj);
HA_EXPORT uint32_t ha_font_get_glyph_count(ha_font_t *obj);
HA_EXPORT uint32_t ha_font_get_upem(ha_font_t *obj);
HA_EXPORT uint32_t ha_font_get_lowest_ppem(ha_font_t *obj);
HA_EXPORT ha_fontmetrics_t ha_font_get_global_metrics(ha_font_t *obj);
HA_EXPORT ha_glyphmetrics_t ha_font_glyph_metrics_for(ha_font_t *obj, uint32_t glyphId);
HA_EXPORT uint32_t ha_font_find_glyph(ha_font_t *obj, uint32_t codepoint);

//
//              FACE OBJECTS
//

HA_EXPORT uint32_t ha_face_get_upem(ha_face_t *obj);
HA_EXPORT float ha_face_get_scale(ha_face_t *obj);
HA_EXPORT float ha_face_get_ppem(ha_face_t *obj);
HA_EXPORT uint32_t ha_face_get_glyph_count(ha_face_t *obj);
HA_EXPORT ha_face_t *ha_face_get_fallback(ha_face_t *obj);
HA_EXPORT void ha_face_set_fallback(ha_face_t *obj, ha_face_t *face);
HA_EXPORT bool ha_face_get_hinting(ha_face_t *obj);
HA_EXPORT void ha_face_set_hinting(ha_face_t *obj, bool value);
HA_EXPORT float ha_face_get_dpi(ha_face_t *obj);
HA_EXPORT void ha_face_set_dpi(ha_face_t *obj, float value);
HA_EXPORT float ha_face_get_pt(ha_face_t *obj);
HA_EXPORT void ha_face_set_pt(ha_face_t *obj, float value);
HA_EXPORT float ha_face_get_px(ha_face_t *obj);
HA_EXPORT void ha_face_set_px(ha_face_t *obj, float value);
HA_EXPORT ha_fontmetrics_t ha_face_get_global_metrics(ha_face_t *obj);
HA_EXPORT ha_glyph_t* ha_face_get_glyph(ha_face_t *obj, uint32_t glyphId, ha_glyph_type_t type);

//
//              GLYPHS
//

HA_EXPORT void ha_glyph_free(ha_glyph_t *obj);
HA_EXPORT ha_glyphmetrics_t ha_glyph_get_metrics(ha_glyph_t* obj);
HA_EXPORT ha_glyph_type_t ha_glyph_get_type(ha_glyph_t *obj);
HA_EXPORT uint32_t ha_glyph_get_id(ha_glyph_t *obj);
HA_EXPORT bool ha_glyph_get_has_data(ha_glyph_t *obj);
HA_EXPORT const char *ha_glyph_get_svg(ha_glyph_t *obj, uint *length);
HA_EXPORT void ha_glyph_rasterize(ha_glyph_t *obj, char **data, uint *length, uint *width, uint *height);
HA_EXPORT void ha_glyph_rasterize_aliased(ha_glyph_t *obj, char **data, uint *length, uint *width, uint *height);

#ifdef __cplusplus
}
#endif

#endif