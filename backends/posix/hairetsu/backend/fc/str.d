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
module hairetsu.backend.fc.str;
import hairetsu.backend.fc.common;

extern(C) nothrow @nogc:

struct FcStrSet;
struct FcStrList;

FcStrSet* FcStrSetCreate ();
FcBool FcStrSetMember (FcStrSet *set, const(char)* s);
FcBool FcStrSetEqual (FcStrSet *sa, FcStrSet *sb);
FcBool FcStrSetAdd (FcStrSet *set, const(char)* s);
FcBool FcStrSetAddFilename (FcStrSet *set, const(char)* s);
FcBool FcStrSetDel (FcStrSet *set, const(char)* s);
void FcStrSetDestroy (FcStrSet *set);
FcStrList* FcStrListCreate (FcStrSet *set);
void FcStrListFirst (FcStrList *list);
char* FcStrListNext (FcStrList *list);
void FcStrListDone (FcStrList *list);
