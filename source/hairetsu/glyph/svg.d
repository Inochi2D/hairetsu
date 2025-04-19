/**
    Hairetsu Glyph SVG Implementation Details

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph.svg;
import hairetsu.common;
import numem;

/**
    Glyph SVG Data
*/
struct HaGlyphSVG {
@nogc:
    string[] data;

    void reset() {
        data = data.nu_resize(0);
    }
}