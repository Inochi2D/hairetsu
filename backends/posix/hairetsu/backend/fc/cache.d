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
module hairetsu.backend.fc.cache;
import hairetsu.backend.fc.common;
import hairetsu.backend.fc.config;

extern(C) nothrow @nogc:

struct FcCache;

const(char)* FcCacheDir (const(FcCache)* c);
FcFontSet* FcCacheCopySet (const(FcCache)* c);
const(char)* FcCacheSubdir (const(FcCache)* c, int i);
int FcCacheNumSubdir (const(FcCache)* c);
int FcCacheNumFont (const(FcCache)* c);
FcBool FcDirCacheUnlink (const(char)* dir, FcConfig *config);
FcBool FcDirCacheValid (const(char)* cache_file);
FcBool FcDirCacheClean (const(char)* cache_dir, FcBool verbose);
void FcCacheCreateTagFile (FcConfig *config);
FcBool FcDirCacheCreateUUID (char* dir, FcBool force, FcConfig* config);
FcBool FcDirCacheDeleteUUID (const(char)* dir, FcConfig* config);
