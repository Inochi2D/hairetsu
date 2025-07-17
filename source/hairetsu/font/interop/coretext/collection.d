/**
    Hairetsu Font Collections for CoreText

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.coretext.collection;
import hairetsu.font.interop.coretext.coretext;
import hairetsu.font.collection;
import hairetsu.font.glyph;
import hairetsu.font.font;
import hairetsu.font.file;
import hairetsu.common;
import nulib.collections.map;
import numem;

version(HA_CORETEXT):

extern(C) FontCollection _ha_fontcollection_from_system(bool update) @nogc {
    CTFontCollection* ctCollection = CTFontCollectionCreateFromAvailableFonts(0);
    CFArray* ctDescriptors = CTFontCollectionCreateMatchingFontDescriptors(ctCollection);

    // Allocate faces; we'll allocate for every font, even unsupported ones.
    // We will be discarding this array anyways.
    FontFaceInfo[] faces = nu_malloca!FontFaceInfo(CFArrayGetCount(ctDescriptors));
    uint faceIdx;

    // Step 1. Get all the valid fonts.
    foreach(i; 0..faces.length) {
        CTFontDescriptor* desc = cast(CTFontDescriptor*)CFArrayGetValueAtIndex(ctDescriptors, cast(CFIndex)i);
        string familyName = desc.copyAttribute!CFString(kCTFontFamilyNameAttribute).toStringReleased();

        // We only want fonts that we can sort.
        if (familyName) {
            CFCharacterSet* charset = desc.copyAttribute!CFCharacterSet(kCTFontCharacterSetAttribute);
            faces[faceIdx] = nogc_new!CTFontFaceInfo(charset);

            faces[faceIdx].familyName = familyName;
            faces[faceIdx].name = desc.copyAttribute!CFString(kCTFontDisplayNameAttribute).toStringReleased();
            faces[faceIdx].postscriptName = desc.copyAttribute!CFString(kCTFontNameAttribute).toStringReleased();
            faces[faceIdx].sampleText = faces[faceIdx].name.nu_dup();
            
            // Parse path.
            CFURL* url = desc.copyAttribute!CFURL(kCTFontURLAttribute);
            faces[faceIdx].path = CFURLCopyFileSystemPath(url, CFURLPathStyle.POSIX).toStringReleased();

            // Parse format.
            CTFontFormat format;
            CFNumber* ctFormat = desc.copyAttribute!CFNumber(kCTFontFormatAttribute);
            CFNumberGetValue(ctFormat, CFNumberGetType(ctFormat), &format);

            // Parse variability.
            CFDictionary* variation = desc.copyAttribute!CFDictionary(kCTFontVariationAttribute);
            if (variation && CFDictionaryGetCount(variation) > 0) faces[faceIdx].variable = true;

            faceIdx++;
        }
    }

    // Step 2. Convert to collection.
    faces = faces[0..faceIdx];
    FontCollection collection = faces.collectionFromFaces();

    // Step 3. Cleanup.
    cast(void)CFRelease(ctDescriptors);
    cast(void)CFRelease(ctCollection);
    return collection;
}

class CTFontFaceInfo : FontFaceInfo {
private:
@nogc:
    CFCharacterSet* charset;

public:

    /**
        Destructor
    */
    ~this() {
        CFRelease(charset);
        charset = null;
    }

    /**
        Constructor
    */
    this(CFCharacterSet* charset) {
        this.charset = CFCharacterSetCreateCopy(null, charset);
    }

    /**
        Gets whether the font has the specified character.

        Params:
            code = The unicode codepoint to query for.
        
        Returns:
            $(D true) if the face has the given unicode code point,
            $(D false) otherwise.
    */
    override
    bool hasCharacter(codepoint code) {
        return CFCharacterSetIsLongCharacterMember(charset, code);
    }
}