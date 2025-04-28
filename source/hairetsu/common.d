/**
    Common Hairetsu functionality and data types.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.common;
public import nulib.math.fixed;
public import nulib.text.unicode;
public import nulib.string;
import numem;

public import hairetsu.ot.tag;
public import hairetsu.ot.script;
public import hairetsu.ot.lang;

public import hairetsu.math;

@nogc nothrow:

/**
    The 32-bit glyph index in a font.

    A glyph index does not match the unicode codepoint
    that it represents, it is internal to the specific font.
*/
alias GlyphIndex = uint;

/**
    Represents a missing glyph, when rendering this
    glyph should indicate to the user that a character
    is not implemented within the font.
*/
enum GlyphIndex GLYPH_MISSING = 0x0u;

/**
    A bitmap containing pixel data.
*/
struct HaBitmap {
@nogc:
    
    /**
        Width of the bitmap
    */
    uint width;
    
    /**
        Height of the bitmap
    */
    uint height;
    
    /**
        Amount of channels in the bitmap
    */
    uint channels;
    
    /**
        Slice into the bitmap
    */
    ubyte[] data;

    /*
        Destructor
    */
    ~this() {
        this.data = data.nu_resize(0);
    }

    /**
        Postblit
    */
    this(this) {
        width = width;
        height = height;
        channels = channels;
        data = data.nu_dup();
    }

    /**
        Constructor
    */
    this(uint width, uint height, uint channels) {
        this.width = width;
        this.height = height;
        this.channels = channels;

        this.data = data.nu_resize(width*height*channels);
        this.clear();
    }

    /**
        Clears data from the bitmap
    */
    void clear() {
        this.data[0..$] = 0;
    }

    /**
        Gets a scanline from the bitmap
    */
    void[] scanline(uint y) {
        if (y >= height)
            return null;

        uint stride = (width*channels);
        uint line = y*stride;
        return cast(void[])data[line..line+stride];
    }
}
