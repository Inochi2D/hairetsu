/**
    Adapted from fontconfig.h

    Copyright © 2001 Keith Packard

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
        Keith Packard
        Luna Nielsen
*/
module hairetsu.backend.fc.match;
import hairetsu.backend.fc.config;
import hairetsu.backend.fc.pattern;
import hairetsu.backend.fc.charset;
import hairetsu.backend.fc.common;

extern(C) nothrow @nogc:

FcPattern* FcFontSetMatch (FcConfig   *config,
                FcFontSet **sets,
                int         nsets,
                FcPattern  *p,
                FcResult   *result);

FcPattern* FcFontMatch (FcConfig  *config,
             FcPattern *p,
             FcResult  *result);

FcPattern* FcFontRenderPrepare (FcConfig  *config,
                     FcPattern *pat,
                     FcPattern *font);

FcFontSet* FcFontSetSort (FcConfig   *config,
               FcFontSet **sets,
               int         nsets,
               FcPattern  *p,
               FcBool      trim,
               FcCharSet **csp,
               FcResult   *result);

FcFontSet* FcFontSort (FcConfig   *config,
            FcPattern  *p,
            FcBool      trim,
            FcCharSet **csp,
            FcResult   *result);

void FcFontSetSortDestroy (FcFontSet *fs);
