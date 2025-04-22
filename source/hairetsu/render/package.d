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
@nogc:
    HaVec2!float pen_;

protected:

    /**
        The position of the pen.
    */
    final
    @property HaVec2!float pen() { return pen_; }

    /**
        Called when rendering begins.
    */
    abstract void renderBegin(HaCanvas canvas);

    /**
        Moves the pen to the given position.

        Note:
            This function is virtual, call it to update
            the actual pen position.
    */
    void moveTo(HaVec2!float target) { this.pen_ = target; }

    /**
        Draws a line to the given point.
    */
    abstract void lineTo(HaVec2!float target);

    /**
        Draws a quadratic bezier spline to the given point.
    */
    abstract void quadTo(HaVec2!float ctrl1, HaVec2!float target);

    /**
        Draws a cubic bezier spline to the given point.
    */
    abstract void cubicTo(HaVec2!float ctrl1, HaVec2!float ctrl2, HaVec2!float target);

    /**
        Begins a new path.
    */
    abstract void closePath();

    /**
        Fills and blits the current outline.

        This should write the final rasterized image to the canvas.
    */
    abstract void blit(HaCanvas canvas);

    /**
        Blits a bitmap to the given position.

        This should write the final rasterized image to the canvas.
    */
    abstract void blit(HaCanvas canvas, HaGlyphBitmap bitmap);

    /**
        Blits an SVG document

        This should write the final rasterized image to the canvas.
    */
    abstract void blit(HaCanvas canvas, HaGlyphSVG svg);
    
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
    HaVec2!float measureGlyphRun(HaFontFace face, ref HaBuffer run) {
        if (!run.isShaped())
            return HaVec2!float(0, 0);
        
        bool isHorizontal = !run.direction.isVertical;
        HaVec2!float size = HaVec2!float(
            0,
            cast(float)(isHorizontal ?
                (face.faceMetrics.ascender.x-face.faceMetrics.descender.x) :
                (face.faceMetrics.ascender.y-face.faceMetrics.descender.y)
            )
        );

        foreach(GlyphIndex idx; run.buffer) {
		    HaGlyphMetrics metrics = face.getMetricsFor(idx);

            size.x += cast(float)(isHorizontal ? 
                metrics.advance.x : 
                metrics.advance.y
            );

            // Bump size if something goes outside the general line height.
            if (cast(float)metrics.size.y > size.y)
                size.y = cast(float)metrics.size.y;
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
    HaVec2!float render(HaFontFace face, ref HaBuffer run, HaVec2!float position, HaCanvas canvas) {
        HaVec2!float accumulator = position;
        HaVec2!fixed26_6 bearing;
        HaVec2!float advance;
        HaGlyph glyph;

        // Early exit, buffer not shaped.
        if (!run.isShaped())
            return accumulator;

        if (run.length == 0)
            return accumulator;
        
        HaGlyphMetrics firstMetrics = face.getMetricsFor(run.buffer[0]);
        bearing = !isVertical(run.direction) ?
            firstMetrics.bearingH :
            firstMetrics.bearingV;

        accumulator.x -= cast(float)bearing.x;
        accumulator.y -= cast(float)bearing.y;
        foreach(GlyphIndex idx; run.buffer) {
            HaVec2!float offset = accumulator;
            glyph = face.getGlyph(idx);
            bearing = !isVertical(run.direction) ?
                glyph.metrics.bearingH :
                glyph.metrics.bearingV;

            // Apply bearing.
            offset.x += cast(float)bearing.x;
            offset.y += cast(float)bearing.y;
            advance = this.render(glyph, offset, canvas);

            accumulator.x += advance.x;
            accumulator.y += advance.y;
        }
        return accumulator;
    }

    /**
        Renders the given glyph to a given buffer.

        Params:
            glyph =     The glyph to render
            position =  The origin position for rendering.
            canvas =    The destination buffer
        
        Returns:
            The horizontal and vertical advance of the glyph
    */
    HaVec2!float render(ref HaGlyph glyph, HaVec2!float position, HaCanvas canvas) {
        HaVec2!float advance = HaVec2!float(
            cast(float)glyph.metrics.advance.x,
            cast(float)glyph.metrics.advance.y,
        );

        if (!this.canRender(glyph))
            return advance;

        this.renderBegin(canvas);
        this.moveTo(position);
        final switch(glyph.type) {
            case HaGlyphType.none:
                break;
            
            case HaGlyphType.outline:

                // TODO: Handle composite outlines.
			    foreach(HaOutlineOp op; glyph.data.outline.commands) {

                    // Offset the rendering positions.
                    HaVec2!float target = HaVec2!float(
                        x: position.x+op.target.x, 
                        y: position.y+op.target.y
                    );
                    HaVec2!float ctrl1 = HaVec2!float(
                        x: position.x+op.control1.x, 
                        y: position.y+op.control1.y
                    );
                    HaVec2!float ctrl2 = HaVec2!float(
                        x: position.x+op.control2.x, 
                        y: position.y+op.control2.y
                    );

				    final switch(op.opcode) {
                        case HaOutlineOpCode.moveTo:
                            this.moveTo(target);
                            break;
                            
                        case HaOutlineOpCode.lineTo:
                            this.lineTo(target);
                            break;
                            
                        case HaOutlineOpCode.quadTo:
                            this.quadTo(ctrl1, target);
                            break;
                            
                        case HaOutlineOpCode.cubicTo:
                            this.cubicTo(ctrl1, ctrl2, target);
                            break;
                            
                        case HaOutlineOpCode.closePath:
                            this.closePath();
                            break;
                    }
                }

                this.blit(canvas);
                break;
                
            case HaGlyphType.bitmap:
                this.blit(canvas, glyph.data.bitmap);
                break;
                
            case HaGlyphType.svg:
                this.blit(canvas, glyph.data.svg);
                break;
        }

        return advance;
    }
}
