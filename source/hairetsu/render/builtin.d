/**
    Hairetsu Built-in Renderer

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.render.builtin;
import hairetsu.render;
import hairetsu.shaper;
import hairetsu.font.glyph;
import hairetsu.font.face;
import hairetsu.common;

import nulib.io.stream;
import nulib.collections.vector;
import numem;


/**
    The built-in Hairetsu renderer.
*/
class HaBuiltinRenderer : HaRenderer {
protected:
@nogc:

    /**
        Fills and blits the current outline.

        This should write the final rasterized image to the canvas.
    */
    override
    void blit(ref Glyph glyph, vec2 offset, HaCanvas canvas, bool horizontal) {
        HaBitmap bitmap = glyph.rasterize(antialiased);

        if (horizontal) {
            offset.y -= glyph.metrics.bounds.height + glyph.metrics.bounds.yMin;
            offset.x -= 2;
        } else {
            offset.y -= 2;
            offset.x -= glyph.metrics.bounds.width/2;
        }

        // Outlines are always monochrome, so just apply it to all of the channels.
        foreach(y; 0..bitmap.height) {

            int ty = (cast(int)offset.y+cast(int)y);
            if (ty < 0)
                continue;
            
            if (ty >= canvas.height)
                continue;

            ubyte[] source = cast(ubyte[])bitmap.scanline(y);
            ubyte[] target = cast(ubyte[])canvas.scanline(ty);
            foreach(x; 0..bitmap.width) {
                int tx = (cast(int)offset.x+cast(int)x)*cast(int)canvas.channels;
                if (tx < 0)
                    continue;
                
                if (tx >= target.length)
                    continue;

                target[tx..tx+canvas.channels] += source[x];
            }
        }
    }

public:

    /**
        Flags indicating the supported rendering formats of the 
        glyph renderer.
    */
    override
    @property HaColorFormat supportedFormats() {
        return HaColorFormat.ARGB32;
    }

    /**
        Flags indicating the capabilities of the renderer.
    */
    override
    @property GlyphRendererCapabilityFlags capabilities() {
        return GlyphRendererCapabilityFlags.supportsOutlines;
    }
}