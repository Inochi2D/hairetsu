/**
    Hairetsu Glyph Rendering Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.render.canvas;
import numem;

import hairetsu.common;


/**
    The color format which to use for rendering.
*/
enum HaColorFormat : uint {
    
    /**
        Aliased 1-bit-per-pixel coverage mask.
    */
    CBPP1 = 0x01,
    
    /**
        Anti-aliased 8-bit-per-pixel coverage mask.
    */
    CBPP8 = 0x02,
    
    /**
        RGBA 32-bit anti-aliased color. 
    */
    RGBA32 = 0x04,
    
    /**
        ARGB 32-bit anti-aliased color. 
    */
    ARGB32 = 0x04
}

/**
    An interface for a render canvas.
*/
abstract
class HaCanvas : NuRefCounted {
public:
@nogc:

    /**
        The color format used by the canvas.
    */
    abstract @property HaColorFormat format();

    /**
        The width of the canvas.
    */
    abstract @property uint width();

    /**
        The height of the canvas.
    */
    abstract @property uint height();

    /**
        The amount of color channels in the canvas.
    */
    abstract @property uint channels();

    /**
        The data of the canvas.
    */
    abstract @property ubyte[] data();
}