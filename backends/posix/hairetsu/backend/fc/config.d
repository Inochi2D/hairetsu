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
module hairetsu.backend.fc.config;
import hairetsu.backend.fc.pattern;
import hairetsu.backend.fc.common;
import hairetsu.backend.fc.blanks;
import hairetsu.backend.fc.str;

extern(C) nothrow @nogc:

struct FcConfig;

char* FcConfigHome ();

FcBool FcConfigEnableHome (FcBool enable);

char* FcConfigGetFilename (FcConfig      *config,
                     const(char)* url);

char* FcConfigFilename (const(char)* url);

FcConfig* FcConfigCreate();

FcConfig* FcConfigReference (FcConfig *config);

void FcConfigDestroy (FcConfig *config);

FcBool FcConfigSetCurrent (FcConfig *config);

FcConfig* FcConfigGetCurrent ();

FcBool FcConfigUptoDate (FcConfig *config);

FcBool FcConfigBuildFonts (FcConfig *config);

FcStrList* FcConfigGetFontDirs (FcConfig *config);

FcStrList* FcConfigGetConfigDirs (FcConfig *config);

FcStrList* FcConfigGetConfigFiles (FcConfig *config);

char* FcConfigGetCache (FcConfig *config);

FcBlanks* FcConfigGetBlanks (FcConfig *config);
 
FcStrList* FcConfigGetCacheDirs (FcConfig *config);

int FcConfigGetRescanInterval (FcConfig *config);

FcBool FcConfigSetRescanInterval (FcConfig *config, int rescanInterval);

FcFontSet* FcConfigGetFonts (FcConfig *config,
                  FcSetName set);

FcBool FcConfigAcceptFont (FcConfig        *config,
                    const FcPattern *font);

FcBool FcConfigAcceptFilter (FcConfig        *config,
                      const FcPattern *font);

FcBool FcConfigAppFontAddFile (FcConfig      *config,
                        const(char)* file);

FcBool FcConfigAppFontAddDir (FcConfig      *config,
                       const(char)* dir);

void FcConfigAppFontClear (FcConfig *config);

FcBool FcConfigSubstituteWithPat (FcConfig   *config,
                           FcPattern  *p,
                           FcPattern  *p_pat,
                           FcMatchKind kind);

FcBool FcConfigSubstitute (FcConfig   *config,
                    FcPattern  *p,
                    FcMatchKind kind);

const(char)*
FcConfigGetSysRoot (const FcConfig *config);

void
FcConfigSetSysRoot (FcConfig      *config,
                    const(char)* sysroot);

FcConfig *
FcConfigSetFontSetFilter (FcConfig           *config,
                          FcFilterFontSetFunc filter_func,
                          FcDestroyFunc       destroy_data_func,
                          void               *user_data);

void
FcConfigFileInfoIterInit (FcConfig             *config,
                          FcConfigFileInfoIter *iter);

FcBool
FcConfigFileInfoIterNext (FcConfig             *config,
                          FcConfigFileInfoIter *iter);

FcBool
FcConfigFileInfoIterGet (FcConfig             *config,
                         FcConfigFileInfoIter *iter,
                         char             **name,
                         char             **description,
                         FcBool               *enabled);

