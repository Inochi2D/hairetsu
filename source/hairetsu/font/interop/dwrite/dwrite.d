/**
    Internal bindings to DirectWrite.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.dwrite.dwrite;
import hairetsu.common;
import nulib.string;
import numem;

version(HA_DIRECTWRITE):
version(Windows):

public import nulib.system.com;

enum DWriteFontFileType : uint {
    UNKNOWN,
    CFF,
    TRUETYPE,
    OPENTYPE_COLLECTION,
    TYPE1_PFM,
    TYPE1_PFB,
    VECTOR,
    BITMAP,
}

bool isFileSupported(DWriteFontFileType type) @nogc {
    switch(type) {
        case DWriteFontFileType.CFF:
        case DWriteFontFileType.TRUETYPE:
        case DWriteFontFileType.OPENTYPE_COLLECTION:
            return true;
        
        default:
            return false;
    }
}

enum DWriteFontFaceType : uint {
    CFF,
    TRUETYPE,
    OPENTYPE_COLLECTION,
    TYPE1,
    VECTOR,
    BITMAP,
    UNKNOWN,
    RAW_CFF,
}

bool isFaceSupported(DWriteFontFaceType type) @nogc {
    switch(type) {
        case DWriteFontFaceType.CFF:
        case DWriteFontFaceType.RAW_CFF:
        case DWriteFontFaceType.TRUETYPE:
        case DWriteFontFaceType.OPENTYPE_COLLECTION:
            return true;
        
        default:
            return false;
    }
}

enum DWriteInformationalStringID : uint {
    NONE,
    COPYRIGHT_NOTICE,
    VERSION_STRINGS,
    TRADEMARK,
    MANUFACTURER,
    DESIGNER,
    DESIGNER_URL,
    DESCRIPTION,
    FONT_VENDOR_URL,
    LICENSE_DESCRIPTION,
    LICENSE_INFO_URL,
    WIN32_FAMILY_NAMES,
    WIN32_SUBFAMILY_NAMES,
    TYPOGRAPHIC_FAMILY_NAMES,
    TYPOGRAPHIC_SUBFAMILY_NAMES,
    SAMPLE_TEXT,
    FULL_NAME,
    POSTSCRIPT_NAME,
    POSTSCRIPT_CID_NAME,
    WEIGHT_STRETCH_STYLE_FAMILY_NAME,
    DESIGN_SCRIPT_LANGUAGE_TAG,
    SUPPORTED_SCRIPT_LANGUAGE_TAG,
}

enum DWriteFactoryType : uint {
    SHARED,
    ISOLATED
}

enum D2D1FactoryType : uint {
    SINGLE_THREADED = 0,
    MULTI_THREADED = 1
}

extern(C) const(IID) IID_ID2D1Factory;

extern(Windows) {
    extern HRESULT DWriteCreateFactory(DWriteFactoryType type, REFIID iid, IUnknown* factory) @nogc;
    extern int GetUserDefaultLocaleName(const(wchar)* lpLocaleName, int cchLocaleName) @nogc;
}

/**
    Gets the default user locale.
*/
wstring getUserDefaultLocaleW() @nogc {
    const(wchar)[] lname = ha_allocarr!(const(wchar))(85);
    
    // Fetch name
    int len = GetUserDefaultLocaleName(lname.ptr, 85);
    if (len) 
        return cast(wstring)lname[0..len-1];
    
    // Name not found.
    ha_freearr(lname);
    return null;
}

@Guid!("b859ee5a-d838-4b5b-a2e8-1adc7d93db48")
interface IDWriteFactory : IUnknown {
extern(Windows):
@nogc:
    __gshared IID iid = __uuidof!IDWriteFactory;

    HRESULT GetSystemFontCollection(ref IDWriteFontCollection fontCollection, bool checkForUpdates=false) pure;
    // Ignore the rest.
}

@Guid!("a84cee02-3eea-4eee-a827-87c1a02a0fcc")
interface IDWriteFontCollection : IUnknown {
extern(Windows):
@nogc:
    uint GetFontFamilyCount() pure;
    HRESULT GetFontFamily(uint index, ref IDWriteFontFamily family) pure;
    HRESULT FindFamilyName(const(wchar)* familyName, ref uint index, ref bool exists) pure;
}

@Guid!("1a0d8438-1d97-4ec1-aef9-a2fb86ed6acb")
interface IDWriteFontList : IUnknown {
extern(Windows):
@nogc:
    HRESULT GetFontCollection(ref IDWriteFontCollection collection) pure;
    uint GetFontCount() pure;
    HRESULT GetFont(uint index, ref IDWriteFont font) pure;
}

@Guid!("da20d8ef-812a-4c43-9802-62ec4abd7add")
interface IDWriteFontFamily : IDWriteFontList {
extern(Windows):
@nogc:
    HRESULT GetFamilyNames(ref IDWriteLocalizedStrings names) pure;
    HRESULT GetFirstMatchingFont(uint weight, uint stretch, uint style, ref IDWriteFont font) pure;
    HRESULT GetMatchingFonts(uint weight, uint stretch, uint style, ref IDWriteFontList fontList) pure;
}

@Guid!("acd16696-8c14-4f5d-877e-fe3fc1d32737")
interface IDWriteFont : IUnknown {
extern(Windows):
@nogc:
    HRESULT GetFontFamily(ref IDWriteFontFamily fontFamily) pure;
    uint GetWeight() pure;
    uint GetStretch() pure;
    uint GetStyle() pure;
    bool IsSymbolFont() pure;
    HRESULT GetFaceNames(ref IDWriteLocalizedStrings names) pure;
    HRESULT GetInformationalStrings(DWriteInformationalStringID sid, IDWriteLocalizedStrings* infoStrings, ref bool exists) pure;
    uint GetSimulations() pure;
    void GetMetrics(void* metrics) pure;
    HRESULT HasCharacter(uint codepoint, ref bool exists) pure;
    HRESULT CreateFontFace(IDWriteFontFace* face) pure;

    /**
        Gets informational string from the font.
    */
    final
    extern(D)
    string getInformationalString(DWriteInformationalStringID sid) @nogc {
        IDWriteLocalizedStrings strings;
        bool exists;
        HRESULT hr;

        hr = this.GetInformationalStrings(sid, &strings, exists);
        if (exists) {

            nstring infstr = strings.getBestString();
            string copy = infstr[].nu_dup();
            return copy;
        }
        return null;
    }
}

@Guid!("727cad4e-d6af-4c9e-8a08-d695b11caa49")
interface IDWriteFontFileLoader : IUnknown {
extern(Windows):
@nogc:
    HRESULT CreateStreamFromKey(const(void)* ffRefKey, uint ffRefKeySize, ref IUnknown ffStream) pure;
}

@Guid!("b2d9f3ec-c9fe-4a11-a2ec-d86208f7c0a2")
interface IDWriteLocalFontFileLoader : IDWriteFontFileLoader {
extern(Windows):
@nogc:
    HRESULT GetFilePathLengthFromKey(const(void)* ffRefKey, uint ffRefKeySize, ref uint fPathLength) pure;
    HRESULT GetFilePathFromKey(const(void)* ffRefKey, uint ffRefKeySize, const(wchar)* fPath, uint fPathSize) pure;
    HRESULT GetLastWriteTimeFromKey(const(void)* ffRefKey, uint ffRefKeySize, void* lastWriteTime) pure;

    final
    nstring getFilePathFromKey(const(void)* key, uint keyLength) {
        uint pLength;
        if (SUCCEEDED(this.GetFilePathLengthFromKey(key, keyLength, pLength))) {
            if (pLength > 0) {
                const(wchar)[] str = ha_allocarr!(const(wchar))(pLength+1);
                if(SUCCEEDED(this.GetFilePathFromKey(key, keyLength, str.ptr, pLength+1))) {
                    nstring ret = str;

                    ha_freearr(str);
                    return ret;
                }

                ha_freearr(str);
            }
        }
        return nstring.init;
    }
}

@Guid!("739d886a-cef5-47dc-8769-1a8b41bebbb0")
interface IDWriteFontFile : IUnknown {
extern(Windows):
@nogc:
    HRESULT GetReferenceKey(ref const(void)* ffRefKeyRef, ref uint ffRefKeySize);
    HRESULT GetLoader(ref IDWriteFontFileLoader loader) pure;
    HRESULT Analyze(ref bool ffIsSupported, ref DWriteFontFileType ffType, void* fType, ref uint faceCount);

    final
    extern(D)
    const(void)[] getReferenceKey() {
        const(void)* refKey;
        uint refKeySize;
        
        if (SUCCEEDED(this.GetReferenceKey(refKey, refKeySize)) && refKey)
            return refKey[0..refKeySize];
        return null;
    }

    final
    extern(D)
    IDWriteLocalFontFileLoader getLocalLoader() {
        const(IID) localLoaderIID = __uuidof!IDWriteLocalFontFileLoader;
        IDWriteFontFileLoader loader = null;
        
        if (SUCCEEDED(this.GetLoader(loader))) {
            void* localLoader;
            if (SUCCEEDED(loader.QueryInterface(&localLoaderIID, localLoader)))
                return cast(IDWriteLocalFontFileLoader)localLoader;
            return null;
        }
        return null;
    }
}

@Guid!("5f49804d-7024-4d43-bfa9-d25984f53849")
interface IDWriteFontFace : IUnknown {
extern(Windows):
@nogc:
    DWriteFontFaceType GetType() pure;
    HRESULT GetFiles(ref uint numberOfFiles, IDWriteFontFile* fontFiles) pure;
    uint GetIndex() pure;

    final
    extern(D)
    IDWriteFontFile[] getFiles() {
        HRESULT hr;
        IDWriteFontFile[] files;
        uint numberOfFiles;

        hr = this.GetFiles(numberOfFiles, null);
        if (SUCCEEDED(hr)) {
            if (numberOfFiles == 0)
                return null;

            // Attempt to read files into files.ptr
            files = ha_allocarr!IDWriteFontFile(numberOfFiles);
            
            hr = this.GetFiles(numberOfFiles, files.ptr);
            if (FAILED(hr)) 
                ha_freearr(files);
        }
        return files;
    }
}

@Guid!("08256209-099a-4b34-b86d-c22b110e7771")
interface IDWriteLocalizedStrings : IUnknown {
extern(Windows):
@nogc:
    uint GetCount() pure;
    HRESULT FindLocaleName(const(wchar)* localeName, uint* index, bool* exists) pure;
    HRESULT GetLocaleNameLength(uint index, ref uint length) pure;
    HRESULT GetLocaleName(uint index, const(wchar)* localeName, uint size) pure;
    HRESULT GetStringLength(uint index, ref uint length) pure;
    HRESULT GetString(uint index, const(wchar)* stringBuffer, uint size) pure;

    /**
        Gets the best locale from a IDWriteLocalizedStrings
    */
    final
    extern(D)
    uint getBestLocale() @nogc {
        uint index = 0;
        bool exists = false;
        HRESULT hr;
        

        wstring locale = getUserDefaultLocaleW();
        if (locale.ptr !is null) {

            hr = this.FindLocaleName(locale.ptr, &index, &exists);
            ha_freearr(locale);

            if (FAILED(hr) || !exists) {
                hr = this.FindLocaleName("en-us", &index, &exists);
                if (FAILED(hr) || !exists) {
                    return 0; // Select first one if none are found.
                }
            }
            return index;
        }
        return 0;
    }

    /**
        Gets the best string from a IDWriteLocalizedStrings
    */
    final
    extern(D)
    string getBestString() @nogc {
        wchar[] str;
        HRESULT hr;
        uint strLen;

        uint index = this.getBestLocale();
        hr = this.GetStringLength(index, strLen);
        if (FAILED(hr)) {
            return null;
        }

        str = ha_allocarr!(wchar)(strLen+1);
        this.GetString(index, str.ptr, strLen+1);

        nstring ret = str[0..strLen];
        ha_freearr(str);
        return ret.nu_dup();
    }
}
