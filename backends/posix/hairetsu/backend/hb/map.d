/**
    Adapted from hb-map.h

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
module hairetsu.backend.hb.map;
import hairetsu.backend.hb.common;
import hairetsu.backend.hb.set;

extern (C) nothrow @nogc:

/**
 * HB_MAP_VALUE_INVALID:
 *
 * Unset #hb_map_t value.
 *
 * Since: 1.7.7
 */
enum HB_MAP_VALUE_INVALID = HB_CODEPOINT_INVALID;

/**
 * hb_map_t:
 *
 * Data type for holding integer-to-integer hash maps.
 *
 **/
struct hb_map_t;


hb_map_t *
hb_map_create ()
    ;

hb_map_t *
hb_map_get_empty ()
    ;

hb_map_t *
hb_map_reference (hb_map_t *map)
    ;

void
hb_map_destroy (hb_map_t *map) 
    ;

hb_bool_t
hb_map_set_user_data (
        hb_map_t           *map,
        hb_user_data_key_t *key,
        void *              data,
        hb_destroy_func_t   destroy,
        hb_bool_t           replace)
    ;

void *
hb_map_get_user_data (
        const hb_map_t     *map,
        hb_user_data_key_t *key)
    ;


/* Returns false if allocation has failed before */
hb_bool_t
hb_map_allocation_successful (const hb_map_t *map)
    ;

hb_map_t *
hb_map_copy (const hb_map_t *map)
    ;

void
hb_map_clear (hb_map_t *map)
    ;

hb_bool_t
hb_map_is_empty (const hb_map_t *map)
    ;

uint
hb_map_get_population (const hb_map_t *map)
    ;

hb_bool_t
hb_map_is_equal (
        const hb_map_t *map,
        const hb_map_t *other)
    ;

uint
hb_map_hash (const hb_map_t *map)
    ;

void
hb_map_set (
        hb_map_t       *map,
        hb_codepoint_t  key,
        hb_codepoint_t  value)
    ;

hb_codepoint_t
hb_map_get (
        const hb_map_t *map,
        hb_codepoint_t  key)
    ;

void
hb_map_del (
        hb_map_t       *map,
        hb_codepoint_t  key)
    ;

hb_bool_t
hb_map_has (
        const hb_map_t *map,
        hb_codepoint_t  key)
    ;

void
hb_map_update (
        hb_map_t *map,
        const hb_map_t *other)
    ;

/* Pass -1 in for idx to get started. */
hb_bool_t
hb_map_next (
        const hb_map_t *map,
        int *idx,
        hb_codepoint_t *key,
        hb_codepoint_t *value)
    ;

void
hb_map_keys (
        const hb_map_t *map,
        hb_set_t *keys)
    ;

void
hb_map_values (
        const hb_map_t *map,
        hb_set_t *values)
    ;
