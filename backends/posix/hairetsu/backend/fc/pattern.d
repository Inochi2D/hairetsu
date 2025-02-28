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
module hairetsu.backend.fc.pattern;
import hairetsu.backend.fc.charset;
import hairetsu.backend.fc.range;
import hairetsu.backend.fc.lang;
import hairetsu.backend.fc.common;

extern(C) nothrow @nogc:

struct FcPattern;

struct FcPatternIter {
private:
    void *dummy1;
    void *dummy2;
}


FcPattern* FcPatternCreate ();
FcPattern* FcPatternDuplicate (const(FcPattern)* p);
void FcPatternReference (FcPattern *p);
FcPattern* FcPatternFilter (FcPattern *p, const(FcObjectSet)* os);
void FcValueDestroy (FcValue v);
FcBool FcValueEqual (FcValue va, FcValue vb);
FcValue FcValueSave (FcValue v);
void FcPatternDestroy (FcPattern *p);
int FcPatternObjectCount (const(FcPattern)* pat);
FcBool FcPatternEqual (const(FcPattern)* pa, const(FcPattern)* pb);
FcBool FcPatternEqualSubset (const(FcPattern)* pa, const(FcPattern)* pb, const(FcObjectSet)* os);
FcChar32 FcPatternHash (const(FcPattern)* p);
FcBool FcPatternAdd (FcPattern *p, const(void)* object, FcValue value, FcBool append);
FcBool FcPatternAddWeak (FcPattern *p, const(void)* object, FcValue value, FcBool append);
FcResult FcPatternGet (const(FcPattern)* p, const(void)* object, int id, FcValue *v);
FcResult FcPatternGetWithBinding (const(FcPattern)* p, const(void)* object, int id, FcValue *v, FcValueBinding *b);
FcBool FcPatternDel (FcPattern *p, const(void)* object);
FcBool FcPatternRemove (FcPattern *p, const(void)* object, int id);
FcBool FcPatternAddInteger (FcPattern *p, const(void)* object, int i);
FcBool FcPatternAddDouble (FcPattern *p, const(void)* object, double d);
FcBool FcPatternAddString (FcPattern *p, const(void)* object, const(char)* s);
FcBool FcPatternAddMatrix (FcPattern *p, const(void)* object, const FcMatrix *s);
FcBool FcPatternAddCharSet (FcPattern *p, const(void)* object, const FcCharSet *c);
FcBool FcPatternAddBool (FcPattern *p, const(void)* object, FcBool b);
FcBool FcPatternAddLangSet (FcPattern *p, const(void)* object, const FcLangSet *ls);
FcBool FcPatternAddRange (FcPattern *p, const(void)* object, const FcRange *r);
FcResult FcPatternGetInteger (const(FcPattern)* p, const(void)* object, int n, int *i);
FcResult FcPatternGetDouble (const(FcPattern)* p, const(void)* object, int n, double *d);
FcResult FcPatternGetString (const(FcPattern)* p, const(void)* object, int n, char **s);
FcResult FcPatternGetMatrix (const(FcPattern)* p, const(void)* object, int n, FcMatrix **s);
FcResult FcPatternGetCharSet (const(FcPattern)* p, const(void)* object, int n, FcCharSet **c);
FcResult FcPatternGetBool (const(FcPattern)* p, const(void)* object, int n, FcBool *b);
FcResult FcPatternGetLangSet (const(FcPattern)* p, const(void)* object, int n, FcLangSet **ls);
FcResult FcPatternGetRange (const(FcPattern)* p, const(void)* object, int id, FcRange **r);
FcPattern* FcPatternBuild (FcPattern *p, ...);
char* FcPatternFormat (FcPattern *pat, const(char)* format);
