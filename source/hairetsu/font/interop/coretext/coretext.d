/**
    Hairetsu Font Collections for CoreText

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.interop.coretext.coretext;
import hairetsu.common;
import nulib.string;
import numem;
import hairetsu.font.glyph;

version(HA_CORETEXT):
enum CFStringEncoding kCFStringEncodingUTF8 = 134217984;

enum CTFontFormat : uint {
    Unrecognized,
    OpenTypePostScript,
    OpenTypeTrueType,
    TrueType,
    PostScript,
    Bitmap
}

GlyphType toGlyphType(CTFontFormat format) @nogc {
    switch(format) {
        case CTFontFormat.TrueType:
        case CTFontFormat.OpenTypeTrueType:
            return GlyphType.trueType;
        
        case CTFontFormat.OpenTypePostScript:
            return GlyphType.cff2;
        
        case CTFontFormat.PostScript:
            return GlyphType.cff;
        
        case CTFontFormat.Bitmap:
            return GlyphType.bitmap;
        
        default:
            return GlyphType.none;
    }
}

extern(C) extern @nogc:

//
//          Minimal CoreFoundation
//


// Base CoreFoundation things.
alias CFIndex = int;
extern void* CFRetain(void*);
extern void* CFRelease(void*);

struct CFArray;
extern CFIndex CFArrayGetCount(CFArray*);
extern void* CFArrayGetValueAtIndex(CFArray*, CFIndex);

struct CFDictionary;
extern CFIndex CFDictionaryGetCount(CFDictionary*);

struct CFString;
alias CFStringEncoding = uint;

extern CFString* CFStringCreateWithCStringNoCopy(void*, const(char)*, CFStringEncoding, void* dealloc = null);
extern const(char)* CFStringGetCStringPtr(CFString*, CFStringEncoding);
extern bool CFStringGetCString(CFString*, char*, CFIndex, CFStringEncoding);
extern CFIndex CFStringGetLength(CFString*);

extern(D)
string toString(CFString* str) {
    CFIndex len = CFStringGetLength(str);
    if (len > 0) {

        // First try the fast route.   
        if (const(char)* name = CFStringGetCStringPtr(str, kCFStringEncodingUTF8)) {
            return cast(string)name[0..len].nu_dup();
        }

        // Slow route, we have to convert ourselves.
        char[] ret = nu_malloca!(char)(len);
        if (CFStringGetCString(str, ret.ptr, len, kCFStringEncodingUTF8))
            return cast(string)ret;
    }
    return null;
}

extern(D)
string toStringReleased(CFString* str) {
    string ret = str.toString();
    cast(void)CFRelease(str);
    return ret;
}

struct CFURL;
enum CFURLPathStyle : CFIndex {
    POSIX,
    HFS,
    WINDOWS
}
extern CFString* CFURLCopyFileSystemPath(CFURL*, CFURLPathStyle);

struct CFNumber;
alias CFNumberType = uint;
extern CFNumberType CFNumberGetType(CFNumber*);
extern bool CFNumberGetValue(CFNumber*, CFNumberType, void*);
extern bool CFNumberIsFloatType(CFNumber*);

struct CFCharacterSet;
extern CFCharacterSet* CFCharacterSetCreateCopy(void*, CFCharacterSet*);
extern bool CFCharacterSetIsLongCharacterMember(CFCharacterSet*, codepoint);

//
//          CoreText
//

alias CTFontCollectionCopyOptions = uint;

struct CTFontCollection;
extern CTFontCollection* CTFontCollectionCreateFromAvailableFonts(CTFontCollectionCopyOptions);
extern CFArray* CTFontCollectionCreateMatchingFontDescriptors(CTFontCollection*);

struct CTFontDescriptor;

extern __gshared const(CFString)* kCTFontURLAttribute;
extern __gshared const(CFString)* kCTFontNameAttribute;
extern __gshared const(CFString)* kCTFontVariationAttribute;
extern __gshared const(CFString)* kCTFontDisplayNameAttribute;
extern __gshared const(CFString)* kCTFontFamilyNameAttribute;
extern __gshared const(CFString)* kCTFontStyleNameAttribute;
extern __gshared const(CFString)* kCTFontTraitsAttribute;
extern __gshared const(CFString)* kCTFontSizeAttribute;
extern __gshared const(CFString)* kCTFontCharacterSetAttribute;
extern __gshared const(CFString)* kCTFontLanguagesAttribute;
extern __gshared const(CFString)* kCTFontFormatAttribute;
extern __gshared const(CFString)* kCTFontEnabledAttribute;
extern void* CTFontDescriptorCopyAttribute(CTFontDescriptor*, CFString*);

extern(D)
T* copyAttribute(T)(CTFontDescriptor* desc, inout(CFString)* key) {
    return cast(T*)CTFontDescriptorCopyAttribute(desc, cast(CFString*)key);
}
