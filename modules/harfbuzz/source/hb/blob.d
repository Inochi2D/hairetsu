/**
    Adapted from hb-blob.h

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
module hairetsu.backend.hb.blob;
import hairetsu.backend.hb.common;

extern(C) nothrow @nogc:

/**
    hb_memory_mode_t:
    @HB_MEMORY_MODE_DUPLICATE: HarfBuzz immediately makes a copy of the data.
    @HB_MEMORY_MODE_READONLY: HarfBuzz client will never modify the data,
       and HarfBuzz will never modify the data.
    @HB_MEMORY_MODE_WRITABLE: HarfBuzz client made a copy of the data solely
       for HarfBuzz, so HarfBuzz may modify the data.
    @HB_MEMORY_MODE_READONLY_MAY_MAKE_WRITABLE: See above

    Data type holding the memory modes available to
    client programs.

    Regarding these various memory-modes:

    -   In no case shall the HarfBuzz client modify memory
        that is passed to HarfBuzz in a blob.  If there is
        any such possibility, @HB_MEMORY_MODE_DUPLICATE should be used
        such that HarfBuzz makes a copy immediately,

    -   Use @HB_MEMORY_MODE_READONLY otherwise, unless you really really
        really know what you are doing,

    -   @HB_MEMORY_MODE_WRITABLE is appropriate if you really made a
        copy of data solely for the purpose of passing to
        HarfBuzz and doing that just once (no reuse!),

    -   If the font is mmap()ed, it's okay to use
        @HB_MEMORY_MODE_READONLY_MAY_MAKE_WRITABLE, however, using that mode
        correctly is very tricky.  Use @HB_MEMORY_MODE_READONLY instead.
*/
enum hb_memory_mode_t {
  HB_MEMORY_MODE_DUPLICATE,
  HB_MEMORY_MODE_READONLY,
  HB_MEMORY_MODE_WRITABLE,
  HB_MEMORY_MODE_READONLY_MAY_MAKE_WRITABLE
}

/**
 * hb_blob_t:
 *
 * Data type for blobs. A blob wraps a chunk of binary
 * data and facilitates its lifecycle management between
 * a client program and HarfBuzz.
 *
 **/
struct hb_blob_t;

hb_blob_t *
hb_blob_create (
        const(ubyte)* data,
        uint length,
        hb_memory_mode_t mode,
        void* user_data,
        hb_destroy_func_t destroy);

hb_blob_t *
hb_blob_create_or_fail (
        const(char)* data,
        uint length,
        hb_memory_mode_t mode,
        void* user_data,
        hb_destroy_func_t destroy);

hb_blob_t *
hb_blob_create_from_file (const(char)* file_name);

hb_blob_t *
hb_blob_create_from_file_or_fail (const(char)* file_name);

/* Always creates with MEMORY_MODE_READONLY.
* Even if the parent blob is writable, we don't
* want the user of the sub-blob to be able to
* modify the parent data as that data may be
* shared among multiple sub-blobs.
*/
hb_blob_t *
hb_blob_create_sub_blob (hb_blob_t* parent, uint offset, uint length);

hb_blob_t *
hb_blob_copy_writable_or_fail (hb_blob_t *blob);

hb_blob_t *
hb_blob_get_empty ();

hb_blob_t *
hb_blob_reference (hb_blob_t *blob);

void
hb_blob_destroy (hb_blob_t *blob);

hb_bool_t
hb_blob_set_user_data (
        hb_blob_t          *blob,
        hb_user_data_key_t *key,
        void *              data,
        hb_destroy_func_t   destroy,
        hb_bool_t           replace);

void* hb_blob_get_user_data(const(hb_blob_t)* blob, hb_user_data_key_t *key);


void hb_blob_make_immutable (hb_blob_t *blob);

hb_bool_t hb_blob_is_immutable (hb_blob_t *blob);


uint hb_blob_get_length (hb_blob_t *blob);

const(ubyte)* hb_blob_get_data (hb_blob_t *blob, uint *length);

ubyte* hb_blob_get_data_writable (hb_blob_t *blob, uint *length);
