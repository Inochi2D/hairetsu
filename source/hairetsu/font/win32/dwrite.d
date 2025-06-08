/**
    Internal bindings to DirectWrite.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.win32.dwrite;
version(Windows):

import nulib.system.com;

enum DWriteFontFileType {
    DWRITE_FONT_FILE_TYPE_UNKNOWN,
    DWRITE_FONT_FILE_TYPE_CFF,
    DWRITE_FONT_FILE_TYPE_TRUETYPE,
    DWRITE_FONT_FILE_TYPE_OPENTYPE_COLLECTION,
    DWRITE_FONT_FILE_TYPE_TYPE1_PFM,
    DWRITE_FONT_FILE_TYPE_TYPE1_PFB,
    DWRITE_FONT_FILE_TYPE_VECTOR,
    DWRITE_FONT_FILE_TYPE_BITMAP,
}

enum DWriteInformationalStringID {
    DWRITE_INFORMATIONAL_STRING_NONE,
    DWRITE_INFORMATIONAL_STRING_COPYRIGHT_NOTICE,
    DWRITE_INFORMATIONAL_STRING_VERSION_STRINGS,
    DWRITE_INFORMATIONAL_STRING_TRADEMARK,
    DWRITE_INFORMATIONAL_STRING_MANUFACTURER,
    DWRITE_INFORMATIONAL_STRING_DESIGNER,
    DWRITE_INFORMATIONAL_STRING_DESIGNER_URL,
    DWRITE_INFORMATIONAL_STRING_DESCRIPTION,
    DWRITE_INFORMATIONAL_STRING_FONT_VENDOR_URL,
    DWRITE_INFORMATIONAL_STRING_LICENSE_DESCRIPTION,
    DWRITE_INFORMATIONAL_STRING_LICENSE_INFO_URL,
    DWRITE_INFORMATIONAL_STRING_WIN32_FAMILY_NAMES,
    DWRITE_INFORMATIONAL_STRING_WIN32_SUBFAMILY_NAMES,
    DWRITE_INFORMATIONAL_STRING_TYPOGRAPHIC_FAMILY_NAMES,
    DWRITE_INFORMATIONAL_STRING_TYPOGRAPHIC_SUBFAMILY_NAMES,
    DWRITE_INFORMATIONAL_STRING_SAMPLE_TEXT,
    DWRITE_INFORMATIONAL_STRING_FULL_NAME,
    DWRITE_INFORMATIONAL_STRING_POSTSCRIPT_NAME,
    DWRITE_INFORMATIONAL_STRING_POSTSCRIPT_CID_NAME,
    DWRITE_INFORMATIONAL_STRING_WEIGHT_STRETCH_STYLE_FAMILY_NAME,
    DWRITE_INFORMATIONAL_STRING_DESIGN_SCRIPT_LANGUAGE_TAG,
    DWRITE_INFORMATIONAL_STRING_SUPPORTED_SCRIPT_LANGUAGE_TAG,
}

enum DWriteFactoryType {
    DWRITE_FACTORY_TYPE_SHARED,
    DWRITE_FACTORY_TYPE_ISOLATED
}

extern(Windows) HRESULT DWriteCreateFactory(DWriteFactoryType type, REFIID iid, ref IUnknown factory) nothrow;

@Guid!("b859ee5a-d838-4b5b-a2e8-1adc7d93db48")
interface IDWriteFactory : IUnknown {
@nogc:
    HRESULT GetSystemFontCollection(ref IDWriteFontCollection fontCollection, bool checkForUpdates=false) pure;
    // Ignore the rest.
}

@Guid!("a84cee02-3eea-4eee-a827-87c1a02a0fcc")
interface IDWriteFontCollection : IUnknown {
@nogc:
    uint GetFontFamilyCount() pure;
    HRESULT GetFontFamily(uint index, ref IDWriteFontFamily family) pure;
    HRESULT FindFamilyName(const(wchar)* familyName, ref uint index, ref bool exists) pure;
}

@Guid!("1a0d8438-1d97-4ec1-aef9-a2fb86ed6acb")
interface IDWriteFontList : IUnknown {
@nogc:
    HRESULT GetFontCollection(ref IDWriteFontCollection collection) pure;
    uint GetFontCount() pure;
    HRESULT GetFont(uint index, ref IDWriteFont font) pure;
}

@Guid!("da20d8ef-812a-4c43-9802-62ec4abd7add")
interface IDWriteFontFamily : IDWriteFontList {
@nogc:
    HRESULT GetFamilyNames(ref IDWriteLocalizedStrings names) pure;
    HRESULT GetFirstMatchingFont(uint weight, uint stretch, uint style, ref IDWriteFont font) pure;
    HRESULT GetMatchingFonts(uint weight, uint stretch, uint style, ref IDWriteFontList fontList) pure;
}

@Guid!("acd16696-8c14-4f5d-877e-fe3fc1d32737")
interface IDWriteFont : IUnknown {
@nogc:
    HRESULT GetFontFamily(ref IDWriteFontFamily fontFamily) pure;
    uint GetWeight() pure;
    uint GetStretch() pure;
    uint GetStyle() pure;
    bool IsSymbolFont() pure;
    HRESULT GetFaceNames(ref IDWriteLocalizedStrings names) pure;
    HRESULT GetInformationalStrings(DWriteInformationalStringID, ref IDWriteLocalizedStrings infoStrings, ref bool exists) pure;
    uint GetSimulations() pure;
    void GetMetrics(void* metrics) pure;
    HRESULT HasCharacter(uint codepoint, ref bool exists) pure;
    HRESULT CreateFontFace(ref IUnknown fontface);
}

@Guid!("727cad4e-d6af-4c9e-8a08-d695b11caa49")
interface IDWriteFontFileLoader : IUnknown {
    HRESULT CreateStreamFromKey(const(void)* ffRefKey, uint ffRefKeySize, ref IUnknown ffStream) pure;
}

@Guid!("b2d9f3ec-c9fe-4a11-a2ec-d86208f7c0a2")
interface IDWriteLocalFontFileLoader : IDWriteFontFileLoader {
    HRESULT GetFilePathLengthFromKey(const(void)* ffRefKey, uint ffRefKeySize, ref uint fPathLength) pure;
    HRESULT GetFilePathFromKey(const(void)* ffRefKey, uint ffRefKeySize, const(wchar)* fPath, uint fPathSize) pure;
    HRESULT GetLastWriteTimeFromKey(const(void)* ffRefKey, uint ffRefKeySize, void* lastWriteTime) pure;
}

@Guid!("739d886a-cef5-47dc-8769-1a8b41bebbb0")
interface IDWriteFontFile : IUnknown {
    HRESULT GetReferenceKey(ref const(void)* ffRefKeyRef, ref uint ffRefKeySize) pure;
    HRESULT GetLoader(ref IDWriteFontFileLoader loader) pure;
    HRESULT Analyze(ref bool ffIsSupported, ref DWriteFontFileType ffType, void* fType, ref uint faceCount);
}

@Guid!("5f49804d-7024-4d43-bfa9-d25984f53849")
interface IDWriteFontFace : IUnknown {
    uint GetType() pure;
    HRESULT GetFiles(ref uint numberOfFiles, IDWriteFontFile* fontFiles) pure;
    uint GetIndex() pure;
}

@Guid!("08256209-099a-4b34-b86d-c22b110e7771")
interface IDWriteLocalizedStrings : IUnknown {
@nogc:
    uint GetCount() pure;
    HRESULT FindLocaleName(const(wchar)* localeName, ref uint index, ref bool exists) pure;
    HRESULT GetLocaleNameLength(uint index, ref uint length) pure;
    HRESULT GetLocaleName(uint index, const(wchar)* localeName, uint size) pure;
    HRESULT GetStringLength(uint index, ref uint length) pure;
    HRESULT GetString(uint index, const(wchar)* stringBuffer, uint size) pure;
}