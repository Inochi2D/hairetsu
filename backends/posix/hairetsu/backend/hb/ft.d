/**
    Adapted from hb-ft.h

    Copyright © 2009  Red Hat, Inc.
    Copyright © 2015  Google, Inc.

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
        Luna Nielsen
*/
module hairetsu.backend.hb.ft;
import hairetsu.backend.hb.face;
import hairetsu.backend.hb.font;
import hairetsu.backend.hb.common;
import hairetsu.backend.ft : FT_Face;

extern (C) nothrow @nogc:

extern hb_face_t* hb_ft_face_create(FT_Face ft_face, hb_destroy_func_t destroy);
extern hb_face_t* hb_ft_face_create_cached(FT_Face ft_face);
extern hb_face_t* hb_ft_face_create_referenced(FT_Face ft_face);
extern hb_font_t* hb_ft_font_create(FT_Face ft_face, hb_destroy_func_t destroy);
extern hb_font_t* hb_ft_font_create_referenced(FT_Face ft_face);
extern FT_Face hb_ft_font_get_face(hb_font_t* font);
extern FT_Face hb_ft_font_lock_face(hb_font_t* font);
extern void hb_ft_font_unlock_face(hb_font_t* font);
extern void hb_ft_font_set_load_flags(hb_font_t* font, int load_flags);
extern int hb_ft_font_get_load_flags(hb_font_t* font);
extern hb_bool_t hb_ft_hb_font_changed(hb_font_t* font);
extern void hb_ft_font_set_funcs(hb_font_t* font);
