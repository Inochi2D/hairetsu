/**
    Adapted from hb-set.h

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
module hairetsu.backend.hb.set;
import hairetsu.backend.hb.common;
import hairetsu.backend.hb.blob;

extern (C) nothrow @nogc:

/**
 * HB_SET_VALUE_INVALID:
 *
 * Unset #hb_set_t value.
 *
 * Since: 0.9.21
 */
enum HB_SET_VALUE_INVALID = HB_CODEPOINT_INVALID;

/**
 * hb_set_t:
 *
 * Data type for holding a set of integers. #hb_set_t's are
 * used to gather and contain glyph IDs, Unicode code
 * points, and various other collections of discrete 
 * values.
 *
 **/
struct hb_set_t;

hb_set_t *
hb_set_create () 
    ;

hb_set_t *
hb_set_get_empty () 
    ;

hb_set_t *
hb_set_reference (hb_set_t *set) 
    ;

void
hb_set_destroy (hb_set_t *set)
    ;

hb_bool_t
hb_set_set_user_data (
        hb_set_t           *set,
        hb_user_data_key_t *key,
        void *              data,
        hb_destroy_func_t   destroy,
        hb_bool_t           replace)
    ;

void *
hb_set_get_user_data (
        const hb_set_t     *set,
        hb_user_data_key_t *key)
    ;


/* Returns false if allocation has failed before */
hb_bool_t
hb_set_allocation_successful (const(hb_set_t)* set)
    ;

hb_set_t *
hb_set_copy (const(hb_set_t)* set)
    ;

void
hb_set_clear (hb_set_t *set)
    ;

hb_bool_t
hb_set_is_empty (const(hb_set_t)* set)
    ;

void
hb_set_invert (hb_set_t *set)
    ;

hb_bool_t
hb_set_is_inverted (const(hb_set_t)* set)
    ;

hb_bool_t
hb_set_has (const(hb_set_t)* set,
        hb_codepoint_t  codepoint)
    ;

void
hb_set_add (
        hb_set_t       *set,
        hb_codepoint_t  codepoint) 
    ;

void
hb_set_add_range (
        hb_set_t       *set,
        hb_codepoint_t  first,
        hb_codepoint_t  last) 
    ;

void
hb_set_add_sorted_array (
        hb_set_t             *set,
        const hb_codepoint_t *sorted_codepoints,
        uint          num_codepoints)
    ;

void
hb_set_del (
        hb_set_t       *set,
        hb_codepoint_t  codepoint)
    ;

void
hb_set_del_range (
        hb_set_t       *set,
        hb_codepoint_t  first,
        hb_codepoint_t  last)
    ;

hb_bool_t
hb_set_is_equal (
        const(hb_set_t)* set,
        const(hb_set_t)* other)
    ;

uint
hb_set_hash (const(hb_set_t)* set)
        ;

hb_bool_t
hb_set_is_subset (
        const(hb_set_t)* set,
        const(hb_set_t)* larger_set)
    ;

void
hb_set_set (
        hb_set_t       *set,
        const(hb_set_t)* other)
    ;

void
hb_set_union (
        hb_set_t       *set,
        const(hb_set_t)* other)
    ;

void
hb_set_intersect (
        hb_set_t       *set,
        const(hb_set_t)* other)
    ;

void
hb_set_subtract (
        hb_set_t       *set,
        const(hb_set_t)* other)
    ;

void
hb_set_symmetric_difference (
        hb_set_t       *set,
        const(hb_set_t)* other)
    ;

uint
hb_set_get_population (const(hb_set_t)* set)
    ;

/* Returns HB_SET_VALUE_INVALID if set empty. */
hb_codepoint_t
hb_set_get_min (const(hb_set_t)* set)
    ;

/* Returns HB_SET_VALUE_INVALID if set empty. */
hb_codepoint_t
hb_set_get_max (const(hb_set_t)* set)
    ;

/* Pass HB_SET_VALUE_INVALID in to get started. */
hb_bool_t
hb_set_next (
        const(hb_set_t)* set,
        hb_codepoint_t *codepoint)
    ;

/* Pass HB_SET_VALUE_INVALID in to get started. */
hb_bool_t
hb_set_previous (
        const(hb_set_t)* set,
        hb_codepoint_t *codepoint)
    ;

/* Pass HB_SET_VALUE_INVALID for first and last to get started. */
hb_bool_t
hb_set_next_range (
        const(hb_set_t)* set,
        hb_codepoint_t *first,
        hb_codepoint_t *last)
    ;

/* Pass HB_SET_VALUE_INVALID for first and last to get started. */
hb_bool_t
hb_set_previous_range (
        const(hb_set_t)* set,
        hb_codepoint_t *first,
        hb_codepoint_t *last)
    ;

/* Pass HB_SET_VALUE_INVALID in to get started. */
//FIXME?: out variable renamed cos it's a keyword in Dlang
uint
hb_set_next_many (
        const(hb_set_t)* set,
        hb_codepoint_t  codepoint,
        hb_codepoint_t *out_,
        uint    size)
    ;