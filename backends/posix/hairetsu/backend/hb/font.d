/**
    Adapted from hb-font.h

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
module hairetsu.backend.hb.font;
import hairetsu.backend.hb.common;
import hairetsu.backend.hb.face;
import hairetsu.backend.hb.draw;
import hairetsu.backend.hb.paint;

extern (C) @nogc nothrow:

/**
    Data type containing a set of virtual methods used for
    working on #hb_font_t font objects.

    HarfBuzz provides a lightweight default function for each of 
    the methods in #hb_font_funcs_t. Client programs can implement
    their own replacements for the individual font functions, as
    needed, and replace the default by calling the setter for a
    method.

*/
struct hb_font_funcs_t;

/* font extents */

/**
    Font-wide extent values, measured in font units.

    Note that typically $(D ascender) is positive and $(D descender)
    negative, in coordinate systems that grow up.
*/
struct hb_font_extents_t {

    /**
        The height of typographic ascenders.
    */
    hb_position_t ascender;

    /**
        The depth of typographic descenders.
    */
    hb_position_t descender;

    /**
        The suggested line-spacing gap.
    */
    hb_position_t line_gap;

    /*< private >*/
    hb_position_t reserved9;
    hb_position_t reserved8;
    hb_position_t reserved7;
    hb_position_t reserved6;
    hb_position_t reserved5;
    hb_position_t reserved4;
    hb_position_t reserved3;
    hb_position_t reserved2;
    hb_position_t reserved1;
}

/* func types */

/**
 * hb_font_get_font_extents_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @extents: (out): The font extents retrieved
 * @user_data: User data pointer passed by the caller
 *
 * This method should retrieve the extents for a font.
 *
 **/
alias hb_font_get_font_extents_func_t =
    hb_bool_t function(
        hb_font_t* font, void* font_data,
        hb_font_extents_t* extents,
        void* user_data);

/**
 * hb_font_get_font_h_extents_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the extents for a font, for horizontal-direction
 * text segments. Extents must be returned in an #hb_glyph_extents output
 * parameter.
 * 
 **/
alias hb_font_get_font_h_extents_func_t = hb_font_get_font_extents_func_t;

/**
 * hb_font_get_font_v_extents_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the extents for a font, for vertical-direction
 * text segments. Extents must be returned in an #hb_glyph_extents output
 * parameter.
 * 
 **/
alias hb_font_get_font_v_extents_func_t = hb_font_get_font_extents_func_t;

/**
 * hb_font_get_nominal_glyph_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @unicode: The Unicode code point to query
 * @glyph: (out): The glyph ID retrieved
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the nominal glyph ID for a specified Unicode code
 * point. Glyph IDs must be returned in a #hb_codepoint_t output parameter.
 * 
 * Return value: `true` if data found, `false` otherwise
 *
 **/
alias hb_font_get_nominal_glyph_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t unicode,
        hb_codepoint_t* glyph,
        void* user_data);

/**
 * hb_font_get_variation_glyph_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @unicode: The Unicode code point to query
 * @variation_selector: The  variation-selector code point to query
 * @glyph: (out): The glyph ID retrieved
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the glyph ID for a specified Unicode code point
 * followed by a specified Variation Selector code point. Glyph IDs must be
 * returned in a #hb_codepoint_t output parameter.
 * 
 * Return value: `true` if data found, `false` otherwise
 *
 **/
alias hb_font_get_variation_glyph_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t unicode, hb_codepoint_t variation_selector,
        hb_codepoint_t* glyph,
        void* user_data);

/**
 * hb_font_get_nominal_glyphs_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @count: number of code points to query
 * @first_unicode: The first Unicode code point to query
 * @unicode_stride: The stride between successive code points
 * @first_glyph: (out): The first glyph ID retrieved
 * @glyph_stride: The stride between successive glyph IDs
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the nominal glyph IDs for a sequence of
 * Unicode code points. Glyph IDs must be returned in a #hb_codepoint_t
 * output parameter.
 *
 * Return value: the number of code points processed
 * 
 **/
alias hb_font_get_nominal_glyphs_func_t =
    uint function(
        hb_font_t* font, void* font_data,
        uint count,
        const hb_codepoint_t* first_unicode,
        uint unicode_stride,
        hb_codepoint_t* first_glyph,
        uint glyph_stride,
        void* user_data);

/**
 * hb_font_get_glyph_advance_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advance for a specified glyph. The
 * method must return an #hb_position_t.
 * 
 * Return value: The advance of @glyph within @font
 *
 **/
alias hb_font_get_glyph_advance_func_t =
    hb_position_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t glyph,
        void* user_data);

/**
 * hb_font_get_glyph_h_advance_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advance for a specified glyph, in
 * horizontal-direction text segments. Advances must be returned in
 * an #hb_position_t output parameter.
 * 
 **/
alias hb_font_get_glyph_h_advance_func_t = hb_font_get_glyph_advance_func_t;

/**
 * hb_font_get_glyph_v_advance_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advance for a specified glyph, in
 * vertical-direction text segments. Advances must be returned in
 * an #hb_position_t output parameter.
 * 
 **/
alias hb_font_get_glyph_v_advance_func_t = hb_font_get_glyph_advance_func_t;

/**
 * hb_font_get_glyph_advances_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @count: The number of glyph IDs in the sequence queried
 * @first_glyph: The first glyph ID to query
 * @glyph_stride: The stride between successive glyph IDs
 * @first_advance: (out): The first advance retrieved
 * @advance_stride: The stride between successive advances
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advances for a sequence of glyphs.
 * 
 **/
//FIXME?: unsigned?
alias hb_font_get_glyph_advances_func_t =
    void function(
        hb_font_t* font, void* font_data,
        uint count,
        const hb_codepoint_t* first_glyph,
        uint glyph_stride,
        hb_position_t* first_advance,
        uint advance_stride,
        void* user_data);

/**
 * hb_font_get_glyph_h_advances_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advances for a sequence of glyphs, in
 * horizontal-direction text segments.
 * 
 **/
alias hb_font_get_glyph_h_advances_func_t = hb_font_get_glyph_advances_func_t;

/**
 * hb_font_get_glyph_v_advances_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advances for a sequence of glyphs, in
 * vertical-direction text segments.
 * 
 **/
alias hb_font_get_glyph_v_advances_func_t = hb_font_get_glyph_advances_func_t;

/**
 * hb_font_get_glyph_origin_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @x: (out): The X coordinate of the origin
 * @y: (out): The Y coordinate of the origin
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the (X,Y) coordinates (in font units) of the
 * origin for a glyph. Each coordinate must be returned in an #hb_position_t
 * output parameter.
 *
 * Return value: `true` if data found, `false` otherwise
 * 
 **/
alias hb_font_get_glyph_origin_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t glyph,
        hb_position_t* x, hb_position_t* y,
        void* user_data);

/**
 * hb_font_get_glyph_h_origin_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the (X,Y) coordinates (in font units) of the
 * origin for a glyph, for horizontal-direction text segments. Each
 * coordinate must be returned in an #hb_position_t output parameter.
 * 
 **/
alias hb_font_get_glyph_h_origin_func_t = hb_font_get_glyph_origin_func_t;

/**
 * hb_font_get_glyph_v_origin_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the (X,Y) coordinates (in font units) of the
 * origin for a glyph, for vertical-direction text segments. Each coordinate
 * must be returned in an #hb_position_t output parameter.
 * 
 **/
alias hb_font_get_glyph_v_origin_func_t = hb_font_get_glyph_origin_func_t;

/**
 * hb_font_get_glyph_kerning_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @first_glyph: The glyph ID of the first glyph in the glyph pair
 * @second_glyph: The glyph ID of the second glyph in the glyph pair
 * @user_data: User data pointer passed by the caller
 *
 * This method should retrieve the kerning-adjustment value for a glyph-pair in
 * the specified font, for horizontal text segments.
 *
 **/
alias hb_font_get_glyph_kerning_func_t =
    hb_position_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t first_glyph, hb_codepoint_t second_glyph,
        void* user_data);
/**
 * hb_font_get_glyph_h_kerning_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the kerning-adjustment value for a glyph-pair in
 * the specified font, for horizontal text segments.
 *
 **/
alias hb_font_get_glyph_h_kerning_func_t = hb_font_get_glyph_kerning_func_t;

/**
 * hb_font_get_glyph_extents_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @extents: (out): The #hb_glyph_extents_t retrieved
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the extents for a specified glyph. Extents must be 
 * returned in an #hb_glyph_extents output parameter.
 *
 * Return value: `true` if data found, `false` otherwise
 * 
 **/
alias hb_font_get_glyph_extents_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t glyph,
        hb_glyph_extents_t* extents,
        void* user_data);

/**
 * hb_font_get_glyph_contour_point_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @point_index: The contour-point index to query
 * @x: (out): The X value retrieved for the contour point
 * @y: (out): The Y value retrieved for the contour point
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the (X,Y) coordinates (in font units) for a
 * specified contour point in a glyph. Each coordinate must be returned as
 * an #hb_position_t output parameter.
 * 
 * Return value: `true` if data found, `false` otherwise
 *
 **/
alias hb_font_get_glyph_contour_point_func_t =
    hb_bool_t function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t glyph, uint point_index,
        hb_position_t* x, hb_position_t* y,
        void* user_data);

/**
 * hb_font_get_glyph_name_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @name: (out) (array length=size): Name string retrieved for the glyph ID
 * @size: Length of the glyph-name string retrieved
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the glyph name that corresponds to a
 * glyph ID. The name should be returned in a string output parameter.
 * 
 * Return value: `true` if data found, `false` otherwise
 *
 **/
alias hb_font_get_glyph_name_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        hb_codepoint_t glyph,
        char* name, uint size,
        void* user_data);

/**
 * hb_font_get_glyph_from_name_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @name: (array length=len): The name string to query
 * @len: The length of the name queried
 * @glyph: (out): The glyph ID retrieved
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the glyph ID that corresponds to a glyph-name
 * string. 
 * 
 * Return value: `true` if data found, `false` otherwise
 *
 **/
alias hb_font_get_glyph_from_name_func_t =
    hb_bool_t
    function(
        hb_font_t* font, void* font_data,
        const char* name, int len, /* -1 means nul-terminated */
        hb_codepoint_t* glyph,
        void* user_data);

/**
 * hb_font_draw_glyph_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @draw_funcs: The draw functions to send the shape data to
 * @draw_data: The data accompanying the draw functions
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * Since: 7.0.0
 *
 **/
// alias hb_font_draw_glyph_func_t =
//     void function(
//         hb_font_t* font, void* font_data,
//         hb_codepoint_t glyph,
//         hb_draw_funcs_t* draw_funcs, void* draw_data,
//         void* user_data);

/**
 * hb_font_paint_glyph_func_t:
 * @font: #hb_font_t to work upon
 * @font_data: @font user data pointer
 * @glyph: The glyph ID to query
 * @paint_funcs: The paint functions to use
 * @paint_data: The data accompanying the paint functions
 * @palette_index: The color palette to use
 * @foreground: The foreground color
 * @user_data: User data pointer passed by the caller
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * Since: 7.0.0
 */
// alias hb_font_paint_glyph_func_t =
//     void function(
//         hb_font_t* font, void* font_data,
//         hb_codepoint_t glyph,
//         hb_paint_funcs_t* paint_funcs, void* paint_data,
//         uint palette_index,
//         hb_color_t foreground,
//         void* user_data);

/**
 * HB_FONT_NO_VAR_NAMED_INSTANCE:
 *
 * Constant signifying that a font does not have any
 * named-instance index set.  This is the default of
 * a font.
 *
 * Since: 7.0.0
 */
enum HB_FONT_NO_VAR_NAMED_INSTANCE = 0xFFFFFFFF;

hb_font_funcs_t* function()
hb_font_funcs_create;

hb_font_funcs_t* function()
hb_font_funcs_get_empty;

hb_font_funcs_t* function(hb_font_funcs_t* ffuncs)
hb_font_funcs_reference;

void function(hb_font_funcs_t* ffuncs)
hb_font_funcs_destroy;

hb_bool_t
function(
    hb_font_funcs_t* ffuncs,
    hb_user_data_key_t* key,
    void* data,
    hb_destroy_func_t destroy,
    hb_bool_t replace)
hb_font_funcs_set_user_data;

void* function(
    const hb_font_funcs_t* ffuncs,
    hb_user_data_key_t* key)
hb_font_funcs_get_user_data;

void function(hb_font_funcs_t* ffuncs)
hb_font_funcs_make_immutable;

hb_bool_t
function(hb_font_funcs_t* ffuncs)
hb_font_funcs_is_immutable;

/* func setters */

/**
* hb_font_funcs_set_font_h_extents_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_font_h_extents_func_t.
*
* Since: 1.1.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_font_h_extents_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_font_h_extents_func;

/**
* hb_font_funcs_set_font_v_extents_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_font_v_extents_func_t.
*
* Since: 1.1.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_font_v_extents_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_font_v_extents_func;

/**
* hb_font_funcs_set_nominal_glyph_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_nominal_glyph_func_t.
*
* Since: 1.2.3
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_nominal_glyph_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_nominal_glyph_func;

/**
* hb_font_funcs_set_nominal_glyphs_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_nominal_glyphs_func_t.
*
* Since: 2.0.0
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_nominal_glyphs_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_nominal_glyphs_func;

/**
* hb_font_funcs_set_variation_glyph_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_variation_glyph_func_t.
*
* Since: 1.2.3
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_variation_glyph_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_variation_glyph_func;

/**
* hb_font_funcs_set_glyph_h_advance_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_h_advance_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_h_advance_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_h_advance_func;

/**
* hb_font_funcs_set_glyph_v_advance_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_v_advance_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_v_advance_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_v_advance_func;

/**
* hb_font_funcs_set_glyph_h_advances_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_h_advances_func_t.
*
* Since: 1.8.6
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_h_advances_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_h_advances_func;

/**
* hb_font_funcs_set_glyph_v_advances_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_v_advances_func_t.
*
* Since: 1.8.6
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_v_advances_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_v_advances_func;

/**
* hb_font_funcs_set_glyph_h_origin_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_h_origin_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_h_origin_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_h_origin_func;

/**
* hb_font_funcs_set_glyph_v_origin_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_v_origin_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_v_origin_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_v_origin_func;

/**
* hb_font_funcs_set_glyph_h_kerning_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_h_kerning_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_h_kerning_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_h_kerning_func;

/**
* hb_font_funcs_set_glyph_extents_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_extents_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_extents_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_extents_func;

/**
* hb_font_funcs_set_glyph_contour_point_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_contour_point_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_contour_point_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_contour_point_func;

/**
* hb_font_funcs_set_glyph_name_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_name_func_t.
*
* Since: 0.9.2
**/
void function(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_name_func_t func,
    void* user_data, hb_destroy_func_t destroy)
hb_font_funcs_set_glyph_name_func;

/**
* hb_font_funcs_set_glyph_from_name_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_get_glyph_from_name_func_t.
*
* Since: 0.9.2
**/
void hb_font_funcs_set_glyph_from_name_func(
    hb_font_funcs_t* ffuncs,
    hb_font_get_glyph_from_name_func_t func,
    void* user_data, hb_destroy_func_t destroy)
;

/**
* hb_font_funcs_set_draw_glyph_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is not needed anymore
*
* Sets the implementation function for #hb_font_draw_glyph_func_t.
*
* Since: 7.0.0
**/
// void hb_font_funcs_set_draw_glyph_func(
//     hb_font_funcs_t* ffuncs,
//     hb_font_draw_glyph_func_t func,
//     void* user_data, hb_destroy_func_t destroy)
// ;

/**
* hb_font_funcs_set_paint_glyph_func:
* @ffuncs: A font-function structure
* @func: (closure user_data) (destroy destroy) (scope notified): The callback function to assign
* @user_data: Data to pass to @func
* @destroy: (nullable): The function to call when @user_data is no longer needed
*
* Sets the implementation function for #hb_font_paint_glyph_func_t.
*
* Since: 7.0.0
*/
// extern void hb_font_funcs_set_paint_glyph_func(
//     hb_font_funcs_t* ffuncs,
//     hb_font_paint_glyph_func_t func,
//     void* user_data, hb_destroy_func_t destroy);

/* func dispatch */

extern hb_bool_t hb_font_get_h_extents(
    hb_font_t* font,
    hb_font_extents_t* extents);
extern hb_bool_t hb_font_get_v_extents(
    hb_font_t* font,
    hb_font_extents_t* extents);

extern hb_bool_t hb_font_get_nominal_glyph(
    hb_font_t* font,
    hb_codepoint_t unicode,
    hb_codepoint_t* glyph);
extern hb_bool_t hb_font_get_variation_glyph(
    hb_font_t* font,
    hb_codepoint_t unicode, hb_codepoint_t variation_selector,
    hb_codepoint_t* glyph);

extern uint hb_font_get_nominal_glyphs(
    hb_font_t* font,
    uint count,
    const hb_codepoint_t* first_unicode,
    uint unicode_stride,
    hb_codepoint_t* first_glyph,
    uint glyph_stride);

extern hb_position_t hb_font_get_glyph_h_advance(
    hb_font_t* font,
    hb_codepoint_t glyph);
extern hb_position_t hb_font_get_glyph_v_advance(
    hb_font_t* font,
    hb_codepoint_t glyph);

//FIXME: unsigned?
extern void hb_font_get_glyph_h_advances(
    hb_font_t* font,
    uint count,
    const hb_codepoint_t* first_glyph,
    uint glyph_stride,
    hb_position_t* first_advance,
    uint advance_stride);
//FIXME: unsigned?
extern void hb_font_get_glyph_v_advances(
    hb_font_t* font,
    uint count,
    const hb_codepoint_t* first_glyph,
    uint glyph_stride,
    hb_position_t* first_advance,
    uint advance_stride);

extern hb_bool_t hb_font_get_glyph_h_origin(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_position_t* x, hb_position_t* y);
extern hb_bool_t hb_font_get_glyph_v_origin(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_position_t* x, hb_position_t* y);

extern hb_position_t hb_font_get_glyph_h_kerning(
    hb_font_t* font,
    hb_codepoint_t left_glyph, hb_codepoint_t right_glyph);

extern hb_bool_t hb_font_get_glyph_extents(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_glyph_extents_t* extents);

extern hb_bool_t hb_font_get_glyph_contour_point(
    hb_font_t* font,
    hb_codepoint_t glyph, uint point_index,
    hb_position_t* x, hb_position_t* y);

extern hb_bool_t hb_font_get_glyph_name(
    hb_font_t* font,
    hb_codepoint_t glyph,
    char* name, uint size);

extern hb_bool_t hb_font_get_glyph_from_name(
    hb_font_t* font,
    const char* name, int len, /* -1 means nul-terminated */
    hb_codepoint_t* glyph);

// extern void hb_font_draw_glyph(
//     hb_font_t* font,
//     hb_codepoint_t glyph,
//     hb_draw_funcs_t* dfuncs, void* draw_data);

// extern void hb_font_paint_glyph(
//     hb_font_t* font,
//     hb_codepoint_t glyph,
//     hb_paint_funcs_t* pfuncs, void* paint_data,
//     uint palette_index,
//     hb_color_t foreground);

/* high-level funcs, with fallback */

/* Calls either hb_font_get_nominal_glyph() if variation_selector is 0,
* otherwise calls hb_font_get_variation_glyph(). */
extern hb_bool_t hb_font_get_glyph(
    hb_font_t* font,
    hb_codepoint_t unicode, hb_codepoint_t variation_selector,
    hb_codepoint_t* glyph);

extern void hb_font_get_extents_for_direction(
    hb_font_t* font,
    hb_direction_t direction,
    hb_font_extents_t* extents);
extern void hb_font_get_glyph_advance_for_direction(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);
extern void
hb_font_get_glyph_advances_for_direction(
    hb_font_t* font,
    hb_direction_t direction,
    uint count,
    const hb_codepoint_t* first_glyph,
    uint glyph_stride,
    hb_position_t* first_advance,
    uint advance_stride);
extern void hb_font_get_glyph_origin_for_direction(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);
extern void hb_font_add_glyph_origin_for_direction(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);
extern void hb_font_subtract_glyph_origin_for_direction(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);

extern void hb_font_get_glyph_kerning_for_direction(
    hb_font_t* font,
    hb_codepoint_t first_glyph, hb_codepoint_t second_glyph,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);

extern hb_bool_t hb_font_get_glyph_extents_for_origin(
    hb_font_t* font,
    hb_codepoint_t glyph,
    hb_direction_t direction,
    hb_glyph_extents_t* extents);

extern hb_bool_t hb_font_get_glyph_contour_point_for_origin(
    hb_font_t* font,
    hb_codepoint_t glyph, uint point_index,
    hb_direction_t direction,
    hb_position_t* x, hb_position_t* y);

/* Generates gidDDD if glyph has no name. */
extern void hb_font_glyph_to_string(
    hb_font_t* font,
    hb_codepoint_t glyph,
    char* s, uint size);
/* Parses gidDDD and uniUUUU strings automatically. */
extern hb_bool_t hb_font_glyph_from_string(
    hb_font_t* font,
    const char* s, int len, /* -1 means nul-terminated */
    hb_codepoint_t* glyph);

/*
* hb_font_t
*/

/* Fonts are very light-weight objects */

extern hb_font_t* hb_font_create(hb_face_t* face);

extern hb_font_t* hb_font_create_sub_font(hb_font_t* parent);

extern hb_font_t* hb_font_get_empty();

extern hb_font_t* hb_font_reference(hb_font_t* font);

extern void hb_font_destroy(hb_font_t* font);

extern hb_bool_t hb_font_set_user_data(
    hb_font_t* font,
    hb_user_data_key_t* key,
    void* data,
    hb_destroy_func_t destroy,
    hb_bool_t replace);

extern void* hb_font_get_user_data(
    const hb_font_t* font,
    hb_user_data_key_t* key);

extern void hb_font_make_immutable(hb_font_t* font);

extern hb_bool_t hb_font_is_immutable(hb_font_t* font);

extern uint hb_font_get_serial(hb_font_t* font);

extern void hb_font_changed(hb_font_t* font);

extern void hb_font_set_parent(
    hb_font_t* font,
    hb_font_t* parent);

extern hb_font_t* hb_font_get_parent(hb_font_t* font);

extern void hb_font_set_face(
    hb_font_t* font,
    hb_face_t* face);

extern hb_face_t* hb_font_get_face(hb_font_t* font);

extern void hb_font_set_funcs(
    hb_font_t* font,
    hb_font_funcs_t* klass,
    void* font_data,
    hb_destroy_func_t destroy);

/* Be *very* careful with this function! */
extern void hb_font_set_funcs_data(
    hb_font_t* font,
    void* font_data,
    hb_destroy_func_t destroy);

extern void hb_font_set_scale(
    hb_font_t* font,
    int x_scale,
    int y_scale);

extern void hb_font_get_scale(
    hb_font_t* font,
    int* x_scale,
    int* y_scale);

/*
* A zero value means "no hinting in that direction"
*/
extern void hb_font_set_ppem(
    hb_font_t* font,
    uint x_ppem,
    uint y_ppem);

extern void hb_font_get_ppem(
    hb_font_t* font,
    uint* x_ppem,
    uint* y_ppem);

/*
* Point size per EM.  Used for optical-sizing in CoreText.
* A value of zero means "not set".
*/
extern void hb_font_set_ptem(hb_font_t* font, float ptem);

extern float hb_font_get_ptem(hb_font_t* font);

extern void hb_font_set_synthetic_bold(hb_font_t* font,
    float x_embolden, float y_embolden,
    hb_bool_t in_place);

extern void hb_font_get_synthetic_bold(hb_font_t* font,
    float* x_embolden, float* y_embolden,
    hb_bool_t* in_place);

extern void hb_font_set_synthetic_slant(hb_font_t* font, float slant);

extern float hb_font_get_synthetic_slant(hb_font_t* font);

extern void hb_font_set_variations(
    hb_font_t* font,
    const hb_variation_t* variations,
    uint variations_length);

extern void hb_font_set_variation(
    hb_font_t* font,
    hb_tag_t tag,
    float value);

extern void hb_font_set_var_coords_design(
    hb_font_t* font,
    const float* coords,
    uint coords_length);

//FIXME: const float *
extern float* hb_font_get_var_coords_design(
    hb_font_t* font,
    uint* length);

extern void hb_font_set_var_coords_normalized(
    hb_font_t* font,
    const int* coords, /* 2.14 normalized */
    uint coords_length);

//FIXME: const int *
extern int* hb_font_get_var_coords_normalized(
    hb_font_t* font,
    uint* length);

extern void hb_font_set_var_named_instance(
    hb_font_t* font,
    uint instance_index);

extern uint hb_font_get_var_named_instance(hb_font_t* font);
