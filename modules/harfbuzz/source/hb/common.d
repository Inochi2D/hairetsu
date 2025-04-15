/**
    Adapted from hb-common.h

    Copyright © 2009  Red Hat, Inc.

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
        Behdad Esfahbod
        Grillo del Mal
*/
module hairetsu.backend.hb.common;

extern(C) nothrow @nogc:

/**
* hb_bool_t:
* 
* Data type for booleans.
*
**/
alias hb_bool_t = bool;

/**
* hb_codepoint_t:
* 
* Data type for holding Unicode codepoints. Also
* used to hold glyph IDs.
*
**/
alias hb_codepoint_t = uint;

/**
* HB_CODEPOINT_INVALID:
*
* Unused #hb_codepoint_t value.
*
* Since: 8.0.0
*/
enum HB_CODEPOINT_INVALID = (cast(hb_codepoint_t) -1);

/**
* hb_position_t:
* 
* Data type for holding a single coordinate value.
* Contour points and other multi-dimensional data are
* stored as tuples of #hb_position_t's.
*
**/
alias hb_position_t = uint;

/**
* hb_mask_t:
* 
* Data type for bitmasks.
*
**/
alias hb_mask_t = uint;

union hb_var_int_t {
    uint u32;
    int i32;
    ushort[2] u16;
    short[2] i16;
    ubyte[4] u8;
    byte[4] i8;
}

union hb_var_num_t {
    float f;
    uint u32;
    int i32;
    ushort[2] u16;
    short[2] i16;
    ubyte[4] u8;
    byte[4] i8;
}


/* hb_tag_t */

/**
* hb_tag_t:
*
* Data type for tag identifiers. Tags are four
* byte integers, each byte representing a character.
*
* Tags are used to identify tables, design-variation axes,
* scripts, languages, font features, and baselines with
* human-readable names.
*
**/
alias hb_tag_t = uint;

/**
    Converts a 4-character ISO15924 string to its numeric equivalent.

    This essentially packs the ISO14924 string into a uint. 
*/
enum uint HB_TAG(immutable(char)[4] tag) = (
    ((cast(uint)(tag[0]) & 0xFF) << 24) | 
    ((cast(uint)(tag[1]) & 0xFF) << 16) | 
    ((cast(uint)(tag[2]) & 0xFF) << 8) |
     (cast(uint)(tag[3]) & 0xFF)
);

alias hb_script_t = uint;

/**
* hb_direction_t:
* @HB_DIRECTION_INVALID: Initial, unset direction.
* @HB_DIRECTION_LTR: Text is set horizontally from left to right.
* @HB_DIRECTION_RTL: Text is set horizontally from right to left.
* @HB_DIRECTION_TTB: Text is set vertically from top to bottom.
* @HB_DIRECTION_BTT: Text is set vertically from bottom to top.
*
* The direction of a text segment or buffer.
* 
* A segment can also be tested for horizontal or vertical
* orientation (irrespective of specific direction) with 
* HB_DIRECTION_IS_HORIZONTAL() or HB_DIRECTION_IS_VERTICAL().
*
*/
enum hb_direction_t {
    HB_DIRECTION_INVALID = 0,
    HB_DIRECTION_LTR = 4,
    HB_DIRECTION_RTL,
    HB_DIRECTION_TTB,
    HB_DIRECTION_BTT
}

/**
* HB_DIRECTION_IS_VALID:
* @dir: #hb_direction_t to test
*
* Tests whether a text direction is valid.
*
**/
bool HB_DIRECTION_IS_VALID(ref uint dir){ return (((dir) & ~3U) == 4); }
/* Direction must be valid for the following */
/**
* HB_DIRECTION_IS_HORIZONTAL:
* @dir: #hb_direction_t to test
*
* Tests whether a text direction is horizontal. Requires
* that the direction be valid.
*
**/
bool HB_DIRECTION_IS_HORIZONTAL(ref uint dir){ return (((dir) & ~1U) == 4); }
/**
* HB_DIRECTION_IS_VERTICAL:
* @dir: #hb_direction_t to test
*
* Tests whether a text direction is vertical. Requires
* that the direction be valid.
*
**/
bool HB_DIRECTION_IS_VERTICAL(ref uint dir){ return (((dir) & ~1U) == 6); }
/**
* HB_DIRECTION_IS_FORWARD:
* @dir: #hb_direction_t to test
*
* Tests whether a text direction moves forward (from left to right, or from
* top to bottom). Requires that the direction be valid.
*
**/
bool HB_DIRECTION_IS_FORWARD(ref uint dir){ return (((dir) & ~2U) == 4); }
/**
* HB_DIRECTION_IS_BACKWARD:
* @dir: #hb_direction_t to test
*
* Tests whether a text direction moves backward (from right to left, or from
* bottom to top). Requires that the direction be valid.
*
**/
bool HB_DIRECTION_IS_BACKWARD(ref uint dir){ return (((dir) & ~2U) == 5); }
/**
* HB_DIRECTION_REVERSE:
* @dir: #hb_direction_t to reverse
*
* Reverses a text direction. Requires that the direction
* be valid.
*
**/
uint HB_DIRECTION_REVERSE(ref uint dir){ return ((dir) ^ 1); }


/* hb_language_t */

/**
 * hb_language_t:
 *
 * Data type for languages. Each #hb_language_t corresponds to a BCP 47
 * language tag.
 *
 */
struct hb_language_impl_t;
alias hb_language_t = hb_language_impl_t *;

/**
 * HB_LANGUAGE_INVALID:
 *
 * An unset #hb_language_t.
 *
 * Since: 0.6.0
 */
enum HB_LANGUAGE_INVALID = (cast(hb_language_t) 0);

/* User data */

/**
* hb_user_data_key_t:
*
* Data structure for holding user-data keys.
*
**/
struct hb_user_data_key_t {
    /*< private >*/
    char unused;
}

/**
* hb_destroy_func_t:
* @user_data: the data to be destroyed
*
* A virtual method for destroy user-data callbacks.
*
*/
alias hb_destroy_func_t = void function(void *user_data);

/* Font features and variations. */

/**
* HB_FEATURE_GLOBAL_START:
*
* Special setting for #hb_feature_t.start to apply the feature from the start
* of the buffer.
*
* Since: 2.0.0
*/
enum HB_FEATURE_GLOBAL_START = 0;

/**
* HB_FEATURE_GLOBAL_END:
*
* Special setting for #hb_feature_t.end to apply the feature from to the end
* of the buffer.
*
* Since: 2.0.0
*/
enum HB_FEATURE_GLOBAL_END = (cast(uint) -1);

/**
* hb_feature_t:
* @tag: The #hb_tag_t tag of the feature
* @value: The value of the feature. 0 disables the feature, non-zero (usually
* 1) enables the feature.  For features implemented as lookup type 3 (like
* 'salt') the @value is a one based index into the alternates.
* @start: the cluster to start applying this feature setting (inclusive).
* @end: the cluster to end applying this feature setting (exclusive).
*
* The #hb_feature_t is the structure that holds information about requested
* feature application. The feature will be applied with the given value to all
* glyphs which are in clusters between @start (inclusive) and @end (exclusive).
* Setting start to #HB_FEATURE_GLOBAL_START and end to #HB_FEATURE_GLOBAL_END
* specifies that the feature always applies to the entire buffer.
*/
struct hb_feature_t {
    hb_tag_t      tag;
    uint      value;
    uint  start;
    uint  end;
}

/**
* hb_variation_t:
* @tag: The #hb_tag_t tag of the variation-axis name
* @value: The value of the variation axis
*
* Data type for holding variation data. Registered OpenType
* variation-axis tags are listed in
* [OpenType Axis Tag Registry](https://docs.microsoft.com/en-us/typography/opentype/spec/dvaraxisreg).
* 
* Since: 1.4.2
*/
struct hb_variation_t {
    hb_tag_t tag;
    float    value;
}

/**
* hb_color_t:
*
* Data type for holding color values. Colors are eight bits per
* channel RGB plus alpha transparency.
*
* Since: 2.1.0
*/
alias hb_color_t = uint;

/* FIXME:???
    HB_EXTERN ubyte
    hb_color_get_alpha (hb_color_t color);

    HB_EXTERN ubyte
    hb_color_get_red (hb_color_t color);

    HB_EXTERN ubyte
    hb_color_get_green (hb_color_t color);

    HB_EXTERN ubyte
    hb_color_get_blue (hb_color_t color);
*/
ubyte hb_color_get_alpha(hb_color_t color){ return  ((color) & 0xFF); }
ubyte hb_color_get_red  (hb_color_t color){ return (((color) >> 8) & 0xFF); }	
ubyte hb_color_get_green(hb_color_t color){ return (((color) >> 16) & 0xFF); }
ubyte hb_color_get_blue (hb_color_t color){ return (((color) >> 24) & 0xFF); }

/**
* hb_glyph_extents_t:
* @x_bearing: Distance from the x-origin to the left extremum of the glyph.
* @y_bearing: Distance from the top extremum of the glyph to the y-origin.
* @width: Distance from the left extremum of the glyph to the right extremum.
* @height: Distance from the top extremum of the glyph to the bottom extremum.
*
* Glyph extent values, measured in font units.
*
* Note that @height is negative, in coordinate systems that grow up.
**/
struct hb_glyph_extents_t {
    hb_position_t x_bearing;
    hb_position_t y_bearing;
    hb_position_t width;
    hb_position_t height;
}

/**
* hb_font_t:
*
* Data type for holding fonts.
*
*/
struct hb_font_t;



/* len=-1 means str is NUL-terminated. */
hb_tag_t
hb_tag_from_string (const char *str, int len)
    ;

/* buf should have 4 bytes. */
void
hb_tag_to_string (hb_tag_t tag, char *buf)
    ;

/* len=-1 means str is NUL-terminated */
hb_direction_t
hb_direction_from_string (const char *str, int len)
    ;

//FIXME: const char *
char *
hb_direction_to_string (hb_direction_t direction)
    ;

hb_language_t
hb_language_from_string (const char *str, int len)
    ;

//FIXME: char *
char *
hb_language_to_string (hb_language_t language)
    ;

hb_language_t
hb_language_get_default ()
    ;

hb_bool_t
hb_language_matches (
        hb_language_t language,
        hb_language_t specific)
    ;

hb_script_t
hb_script_from_iso15924_tag (hb_tag_t tag)
    ;

hb_script_t
hb_script_from_string (const char *str, int len)
    ;

hb_tag_t
hb_script_to_iso15924_tag (hb_script_t script)
    ;

hb_direction_t
hb_script_get_horizontal_direction (hb_script_t script)
    ;

hb_bool_t
hb_feature_from_string (
        const char *str, int len,
        hb_feature_t *feature) 
    ;

void
hb_feature_to_string (
        hb_feature_t *feature,
        char *buf, uint size) 
    ;

hb_bool_t
hb_variation_from_string (
        const char *str, int len,
        hb_variation_t *variation)
    ;

void
hb_variation_to_string (
        hb_variation_t *variation,
        char *buf, uint size)
    ;
