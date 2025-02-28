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
module hairetsu.backend.fc.blanks;
import hairetsu.backend.fc.common;

extern(C) nothrow @nogc:

struct FcBlanks;

FcBlanks* FcBlanksCreate ();
void FcBlanksDestroy (FcBlanks *b);
FcBool FcBlanksAdd (FcBlanks *b, FcChar32 ucs4);
FcBool FcBlanksIsMember (FcBlanks *b, FcChar32 ucs4);
