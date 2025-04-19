/**
    Hairetsu Glyph Rendering Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.renderer;
import hairetsu.font.face;
import hairetsu.glyph;
import nulib.io.stream;
import numem;

import hairetsu.common;

/**
    The color format which to use for rendering.
*/
enum HaGlyphRendererFormat : uint {
    
    /**
        Aliased 1-bit-per-pixel coverage mask.
    */
    CBPP1,
    
    /**
        Anti-aliased 8-bit-per-pixel coverage mask.
    */
    CBPP8,
    
    /**
        ARGB 32-bit anti-aliased color. 
    */
    ARGB32
}

enum HaGlyphRendererCapabilityFlags : uint {
    
    /**
        Flag indicating that the renderer supports rendering
        bitmaps.
    */
    supportsBitmaps     = (1 << 0),
    
    /**
        Flag indicating that the renderer supports rendering
        vector outlines.
    */
    supportsOutlines    = (1 << 1),
    
    /**
        Flag indicating that the renderer supports rendering
        SVGs.
    */
    supportsSVG         = (1 << 2),
}

/**
    The base interface of glyph renderers.
*/
abstract
class HaGlyphRenderer : NuObject {
public:
@nogc:

    /**
        The rendering format to use.
    */
    HaGlyphRendererFormat renderFormat;

    /**
        Returns flags indicating the capabilities of the renderer.
    */
    abstract @property HaGlyphRendererCapabilityFlags capabilities();

    /**
        Checks whether the renderer can render the given glyph.

        Params:
            glyph = The glyph to query
        
        Returns:
            $(D true) if the renderer reports the ability to
            render the given glyph, $(D false) otherwise.
    */
    final
    bool canRender(ref HaGlyph glyph) {
        final switch(glyph.type) {
            case HaGlyphType.none:
                return false;
            
            case HaGlyphType.bitmap:
                return (capabilities & HaGlyphRendererCapabilityFlags.supportsBitmaps) > 0;
            
            case HaGlyphType.outline:
                return (capabilities & HaGlyphRendererCapabilityFlags.supportsOutlines) > 0;
            
            case HaGlyphType.svg:
                return (capabilities & HaGlyphRendererCapabilityFlags.supportsSVG) > 0;
        }
    }

    /**
        Renders the active glyph of the given face to the buffer.

        If the renderer reports being unable to render the glyph,
        the .nodef glyph will be tried instead.

        Params:
            face =      The font face to render
            index =     The index of the glyph to render
            buffer =    The destination buffer
        
        Returns:
            $(D true) if the glyph was rendered,
            $(D false) otherwise.
    */
    final
    bool render(HaFontFace face, GlyphIndex index, ubyte[] buffer) {
        if (!this.canRender(face.getGlyph(index))) 
            return this.render(face.getGlyph(GLYPH_MISSING), buffer);
        

        // Otherwise, we just go with
        return this.render(face.getGlyph(index), buffer);
    }  

    /**
        Renders the given glyph to a given buffer.

        Params:
            glyph =     The glyph to render
            buffer =    The destination buffer
        
        Returns:
            $(D true) if the glyph was rendered,
            $(D false) otherwise.
    */
    abstract bool render(ref HaGlyph glyph, ubyte[] buffer);
}
