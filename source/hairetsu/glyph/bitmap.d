/**
    Hairetsu Glyph Bitmap Implementation Details

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph.bitmap;
import hairetsu.common;
import numem;

/**
    A bitmap stored in a glyph.
*/
struct HaGlyphBitmap {
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

    /**
        Clears data from the bitmap
    */
    void reset() {
        data = data.nu_resize(0);
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

