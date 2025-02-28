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
module hairetsu.backend.fc.range;
import hairetsu.backend.fc.common;
import hairetsu.backend.fc.pattern;

extern (C) nothrow @nogc:

struct FcRange;

FcRange* FcRangeCreateDouble (double begin, double end);
FcRange* FcRangeCreateInteger (FcChar32 begin, FcChar32 end);
void FcRangeDestroy (FcRange *range);
FcRange* FcRangeCopy (const(FcRange)*  r);
FcBool FcRangeGetDouble (const(FcRange)*  range, double *begin, double *end);
void FcPatternIterStart (const(FcPattern)*  pat, FcPatternIter *iter);
FcBool FcPatternIterNext (const(FcPattern)*  pat, FcPatternIter *iter);
FcBool FcPatternIterEqual (const(FcPattern)*  p1, FcPatternIter *i1, const(FcPattern)*  p2, FcPatternIter *i2);
FcBool FcPatternFindIter (const(FcPattern)*  pat, FcPatternIter *iter, const (char) *object);
FcBool FcPatternIterIsValid (const(FcPattern)*  pat, FcPatternIter *iter);
const(char)* FcPatternIterGetObject (const(FcPattern)*  pat, FcPatternIter *iter);
int FcPatternIterValueCount (const(FcPattern)*  pat, FcPatternIter *iter);
FcResult FcPatternIterGetValue (const(FcPattern)*  pat, FcPatternIter *iter, int id, FcValue *v, FcValueBinding *b);
