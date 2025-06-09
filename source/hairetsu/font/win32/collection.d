/**
    Hairetsu Font Collections for Windows

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.win32.collection;
import hairetsu.font.win32.dwrite;

version(Windows):

import hairetsu.font.collection;
import hairetsu.font.win32.dwrite;
import hairetsu.common;
import numem;

__gshared IDWriteFactory _ha_dwrite_factory;
void _ha_win32_fontcollection_init() @nogc {
    if (!_ha_dwrite_factory) {
        DWriteCreateFactory(DWriteFactoryType.SHARED, &IDWriteFactory.iid, cast(IUnknown*)&_ha_dwrite_factory);
    }
}

/**
    Function to enumerate the system fonts.
*/
extern(C) FontCollection _ha_fontcollection_from_system(bool update) @nogc {
    _ha_win32_fontcollection_init();

    FontCollection collection = nogc_new!FontCollection();
    if (!_ha_dwrite_factory)
        return collection;

    // Get the DWrite font collections. 
    IDWriteFontCollection dwriteCollection;
    _ha_dwrite_factory.GetSystemFontCollection(dwriteCollection, update);

    foreach(i; 0..dwriteCollection.GetFontFamilyCount()) {
        FontFamily family = nogc_new!FontFamily();

        // Look up font family.
        IDWriteFontFamily dwriteFamily;
        if (SUCCEEDED(dwriteCollection.GetFontFamily(cast(uint)i, dwriteFamily))) {

            // Try to get its name.
            IDWriteLocalizedStrings dwriteFamilyNameStrings;
            if (SUCCEEDED(dwriteFamily.GetFamilyNames(dwriteFamilyNameStrings))) {
                nstring fname = dwriteFamilyNameStrings.getBestString();
                family.familyName = fname[].nu_dup();
            }

            uint fontCount = dwriteFamily.GetFontCount();
            foreach(f; 0..fontCount) {
                IDWriteFont font;
                if (SUCCEEDED(dwriteFamily.GetFont(f, font))) {
                    DWriteFontFaceInfo vFace = nogc_new!DWriteFontFaceInfo(font);
                    if(vFace.isValidFont) {
                        vFace.retain();
                        family.addFace(vFace);
                    }

                    vFace.release();
                }
            }
        }

        if (family.faces.length > 0) {
            family.retain();
            collection.addFamily(family);
        }
        family.release();
    }

    return collection;
}

/**
    DirectWrite virtual font.
*/
class DWriteFontFaceInfo : FontFaceInfo {
private:
@nogc:
    IDWriteFont _font;

    void setPathFromFont(IDWriteFont font) {
        
        IDWriteFontFace face;
        if (SUCCEEDED(font.CreateFontFace(&face))) {
            if (!face.GetType().isFaceSupported) {
                face.Release();
                return;
            }

            IDWriteFontFile[] files = face.getFiles();
            if (files.length > 0) {
                foreach(i, ref IDWriteFontFile file; files) {
                    const(void)[] key = file.getReferenceKey();
                    if (auto loader = file.getLocalLoader()) {
                        nstring path = loader.getFilePathFromKey(key.ptr, cast(uint)key.length);
                        if (!path.ptr)
                            continue;

                        this.setData(path[].nu_dup());
                        break;
                    }
                }
                ha_freearr(files);
            }
            face.Release();
        }
    }

    void setInfoFromFont(IDWriteFont font) {
        this.name = font.getInformationalString(DWriteInformationalStringID.FULL_NAME);
        this.postscriptName = font.getInformationalString(DWriteInformationalStringID.POSTSCRIPT_NAME);
        this.familyName = font.getInformationalString(DWriteInformationalStringID.TYPOGRAPHIC_FAMILY_NAMES);
        this.subfamilyName = font.getInformationalString(DWriteInformationalStringID.TYPOGRAPHIC_SUBFAMILY_NAMES);
        this.sampleText = font.getInformationalString(DWriteInformationalStringID.SAMPLE_TEXT);
    }

public:

    /**
        Destructor
    */
    ~this() {
        this._font.Release();
    }

    /**
        Creates virtual font from dwrite font and face.
    */
    this(IDWriteFont font) {
        this._font = font;
        this.setPathFromFont(font);
        this.setInfoFromFont(font);
    }

    /**
        Gets whether the font has the specified character.
    */
    override
    bool hasCharacter(codepoint character) {
        bool exists;
        _font.HasCharacter(character, exists);
        return exists;
    }
}