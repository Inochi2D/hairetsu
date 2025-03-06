/**
    Hairetsu Font Families

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.family;
import nulib.string;
import numem;

/**
    A family of fonts.

    Lifetime:
        HaFontFamily's lifetime is managed by HaFontManager,
        as such you should not call nogc_delete on the object.
        Doing so will likely lead to crashes.
        To free font families, free their owning font manager.
*/
abstract
class HaFontFamily : NuObject {
@nogc:
public:

    /**
        Name of the font family.
    */
    abstract @property string familyName() @safe;

    /**
        Enumerates all of the font faces in a family.
    */
    abstract @property HaFontDescriptor[] faces() @safe;
}

/**
    The format of the given font.
*/
enum HaFontFormat : uint {
    
    /**
        Font format is unknown.
    */
    unknown = 0x00,
    
    /**
        Font format is OpenType
    */
    openType = 0x01,
    
    /**
        Font format is TrueType
    */
    trueType = 0x02,

    /**
        Font format is Adobe Type1
    */
    type1 = 0x03,
    
    /**
        Font format is non-scalable bitmap sequence.
    */
    bitmap = 0x04,
}

/**
    A descriptor used to create a font from a system font.

    Lifetime:
        HaFontDescriptor belongs to the font family that created it.
        The descriptor is freed once its parent family is freed.
*/
struct HaFontDescriptor {
@nogc:
public:

    /**
        Underlying handle of the font descriptor.

        Generally should not be used directly; maps to
        a system-specific "descriptor" or font reference.
    */
    void* handle;

    /**
        The family the font belongs to.
    */
    HaFontFamily family;

    /**
        The name of the font.
    */
    string name;

    /**
        The style of the font.
    */
    string style;

    /**
        The format of the font
    */
    HaFontFormat format;

    /**
        Whether the font is variable
    */
    bool isVariable;

    /**
        Whether the font is monospaced
    */
    bool isMonospaced;
}


