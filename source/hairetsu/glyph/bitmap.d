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
    uint width;
    uint height;
    uint channels;
    ubyte[] data;
    
    void reset() {
        data = data.nu_resize(0);
    }
}

