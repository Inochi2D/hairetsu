/**
    Hairetsu Font Collections for DirectWrite

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.dwrite.collection;
import hairetsu.font.interop.dwrite.dwrite;
import hairetsu.font.collection;
import hairetsu.font.font;
import hairetsu.font.file;
import hairetsu.common;
import numem;

version(HA_DIRECTWRITE):
version(Windows):

__gshared IDWriteFactory _ha_dwrite_factory;
void _ha_dwrite_fontcollection_init() @nogc {
    if (!_ha_dwrite_factory) {
        DWriteCreateFactory(DWriteFactoryType.SHARED, &IDWriteFactory.iid, cast(IUnknown*)&_ha_dwrite_factory);
    }
}

/**
    Function to enumerate the system fonts.
*/
extern(C) FontCollection _ha_fontcollection_from_system(bool update) @nogc {
    _ha_dwrite_fontcollection_init();

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
                    if(vFace.isRealizable) {
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
    int index;
    IDWriteFont font;

    void setPathFromFont() {
        import std.stdio : printf;

        IDWriteFontFace face;
        if (SUCCEEDED(font.CreateFontFace(&face))) {
            if (!face.GetType().isFaceSupported) {
                face.Release();
                return;
            }

            this.index = face.GetIndex();

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

    void setInfoFromFont() {
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
        this.font.Release();
    }

    /**
        Creates virtual font from dwrite font and face.
    */
    this(IDWriteFont font) {
        this.font = font;
        
        this.setPathFromFont();

        // This is broken on LDC??
        version(LDC) { } else this.setInfoFromFont();
    }

    /**
        Gets whether the font has the specified character.
    */
    override
    bool hasCharacter(codepoint character) {
        bool exists;
        font.HasCharacter(character, exists);
        return exists;
    }

    /**
        Realises the font face into a Hairetsu font object.

        Returns:
            The font created from the font info.
    */
    override
    Font realize() {
        if (!path)
            return null;

        return this.realizeFromFile(FontFile.fromFile(path), index);
    }
}