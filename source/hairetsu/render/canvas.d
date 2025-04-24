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
import hairetsu.glyph.bitmap;

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
    ARGB32 = 0x08
}

/**
    An interface for a render canvas.
*/
final
class HaCanvas : NuRefCounted {
private:
@nogc:
    // Just reusing our existing glyph bitmap.
    HaGlyphBitmap bitmap;
    HaColorFormat format_;

    uint getChannelCount(HaColorFormat format) {
        final switch(format) {
            case HaColorFormat.CBPP1:
            case HaColorFormat.CBPP8:
                return 1;
                
            case HaColorFormat.RGBA32:
            case HaColorFormat.ARGB32:
                return 4;
        }
    }

public:
    ~this() {
        bitmap.reset();
    }

    this(uint width, uint height, HaColorFormat format) {
        uint c = getChannelCount(format);

        this.format_ = format;
        this.bitmap.width = width;
        this.bitmap.height = height;
        this.bitmap.channels = c;
        this.bitmap.data = this.bitmap.data.nu_resize(width*height*c);
        nogc_zeroinit(bitmap.data[]);
    }

    /**
        The color format used by the canvas.
    */
    @property HaColorFormat format() { return this.format_; }

    /**
        The width of the canvas.
    */
    @property uint width() { return bitmap.width; }

    /**
        The height of the canvas.
    */
    @property uint height() { return bitmap.height; }

    /**
        The amount of color channels in the canvas.
    */
    @property uint channels() { return bitmap.channels; }

    /**
        Gets a slice of the given scanline of the canvas.
    */
    void[] scanline(int y) { return bitmap.scanline(y); }

    /**
        Takes ownership of the internal bitmap.
    */
    HaGlyphBitmap take() {
        auto bitmap = this.bitmap;
        nogc_initialize(this.bitmap);
        return bitmap;
    }
}
