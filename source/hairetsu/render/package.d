/**
    Hairetsu Glyph Rendering Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.render;
import hairetsu.font.face;
import hairetsu.shaper;
import hairetsu.glyph;
import nulib.io.stream;
import numem;

import hairetsu.common;

public import hairetsu.render.canvas;
import hairetsu.render.builtin;

/**
    Compatibility flags
*/
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
    The base interface for renderers.
*/
abstract
class HaRenderer : NuRefCounted {
private:
protected:

    /**
        Blits the given glyph to the canvas.

        This should write the final rasterized image to the canvas.
    */
    abstract void blit(ref HaGlyph glyph, vec2 offset, HaCanvas canvas, bool horizontal);
    
public:

    /**
        Flags indicating the supported rendering formats of the 
        glyph renderer.
    */
    abstract @property HaColorFormat supportedFormats();

    /**
        Flags indicating the capabilities of the renderer.
    */
    abstract @property HaGlyphRendererCapabilityFlags capabilities();

    /**
        Whether to apply anti-aliasing.
    */
    bool antialiased = true;

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
        Gets whether the renderer can render to the given canvas.

        Params:
            canvas = The canvas to query.

        Returns:
            $(D true) if the renderer can render to the canvas,
            $(D false) otherwise.
    */
    final
    bool canRenderTo(HaCanvas canvas) {
        return (canvas.format & supportedFormats) != 0;
    }

    /**
        Measures a shaped glyph run

        Params:
            face =  The font face to use the metrics from.
            run =   The glyph run to measure.

        Returns:
            A vector indicating the overall width and height of
            the text run. If the run wasn't shaped, it will 
            instead return a zero vector.
    */
    vec2 measureGlyphRun(HaFontFace face, ref HaBuffer run) {
        if (!run.isShaped())
            return vec2(0, 0);
        
        bool isHorizontal = !run.direction.isVertical;
        vec2 size = vec2(0, 0);
        if (isHorizontal) {
            float lineHeight = max(face.faceMetrics.ascender.x - face.faceMetrics.descender.x, face.faceMetrics.lineGap.y);
            foreach(GlyphIndex idx; run.buffer) {
                HaGlyphMetrics metrics = face.getMetricsFor(idx);
                size.x += metrics.advance.x;

                if (lineHeight > size.y)
                    size.y = lineHeight;
                
                lineHeight = metrics.bounds.height+metrics.bearing.x;
            }

        } else {
            float lineHeight = max(face.faceMetrics.ascender.y - face.faceMetrics.descender.y, face.faceMetrics.lineGap.y);
            foreach(GlyphIndex idx; run.buffer) {
                HaGlyphMetrics metrics = face.getMetricsFor(idx);
                size.y += metrics.advance.y;

                if (lineHeight > size.x)
                    size.x = lineHeight;
                
                lineHeight = metrics.bounds.height+metrics.bearing.y;
            }

        }
        return size;
    }

    /**
        Renders the given shaped text run using the given face at the 
        specified position.

        Params:
            face =      The face to render with.
            run =       The shaped text run
            position =  Where the text should begin within the canvas.
            canvas =    The canvas to render to.

        Returns:
            The resulting accumulated text advance. If the run wasn't 
            shaped, it will instead return a zero vector.
    */
    vec2 render(HaFontFace face, ref HaBuffer run, vec2 position, HaCanvas canvas) {
        vec2 accumulator = position;
        vec2 bearing;
        vec2 advance;
        HaGlyph glyph;

        // Early exit, buffer not shaped.
        if (!run.isShaped())
            return accumulator;

        if (run.length == 0)
            return accumulator;
        
        bool isHorizontal = !isVertical(run.direction);
        foreach(GlyphIndex idx; run.buffer) {
            vec2 offset = accumulator;
            glyph = face.getGlyph(idx);

            bearing = vec2(
                isHorizontal ? glyph.metrics.bearing.x : 0,
                isHorizontal ? 0 : glyph.metrics.bearing.y,
            );

            offset += bearing;
            advance = this.render(glyph, offset, canvas, isHorizontal);

            if (isHorizontal)
                accumulator.x += advance.x;
            else
                accumulator.y += advance.y;
        }
        return accumulator;
    }

    /**
        Renders the given glyph to a given buffer.

        Params:
            glyph =         The glyph to render
            position =      The origin position for rendering.
            canvas =        The destination buffer
            horizontal =    Whether to render with horizontal or vertical metrics.
        
        Returns:
            The horizontal and vertical advance of the glyph
    */
    vec2 render(ref HaGlyph glyph, vec2 position, HaCanvas canvas, bool horizontal = true) {
        vec2 advance = vec2(
            cast(float)glyph.metrics.advance.x,
            cast(float)glyph.metrics.advance.y,
        );

        if (!this.canRender(glyph))
            return advance;
        
        this.blit(glyph, position, canvas, horizontal);
        return advance;
    }

    /**
        Creates an instance of the builtin renderer.
    */
    static HaRenderer createBuiltin() {
        return nogc_new!HaBuiltinRenderer();
    }
}
