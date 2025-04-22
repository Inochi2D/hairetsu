module renderer;
import hairetsu.render;
import hairetsu.common;
import hairetsu.glyph;
import canvasity;
import gamut;

class GamutCanvas : HaCanvas {
private:
@nogc:
    Image image;

public:

    /**
        Constructor
    */
    this(uint width, uint height) {
        image.create(width, height, PixelType.rgba8);

        image.layer(0);

        foreach(y; 0..image.height) {
            ubyte* scanptr = cast(ubyte*)image.scanptr(y);
            foreach(_; 0..image.width * image.channels) {
                *scanptr = 0xFF;
                scanptr++;
            }
        }
    }

    /**
        The color format used by the canvas.
    */
    override @property HaColorFormat format() { return HaColorFormat.RGBA32; }

    /**
        The width of the canvas.
    */
    override @property uint width() { return image.width(); }

    /**
        The height of the canvas.
    */
    override @property uint height() { return image.width(); }

    /**
        The amount of color channels in the canvas.
    */
    override @property uint channels() { return image.channels(); }

    /**
        The data of the canvas.
    */
    override @property ubyte[] data() {
        return image.allPixelsAtOnce;
    }

    bool saveToPNG(string path) {
        return image.saveToFile(ImageFormat.PNG, path);
    }
}

class CanvasityRenderer : HaRenderer {
private:
@nogc:
    Canvasity canvasity;

protected:

    // Outlines

    /**
        Begins a new path.
    */
    override
    void renderBegin(HaCanvas canvas) {
        canvasity.initialize((cast(GamutCanvas)canvas).image);
    }

    override
    void moveTo(HaVec2!float target) {
        super.moveTo(target);
        canvasity.moveTo(target.x, target.y);
    }

    /**
        Draws a line to the given point.
    */
    override
    void lineTo(HaVec2!float target) {
        canvasity.lineTo(target.x, target.y);
    }

    /**
        Draws a quadratic bezier spline to the given point.
    */
    override
    void quadTo(HaVec2!float ctrl1, HaVec2!float target) {
        canvasity.quadraticCurveYo(ctrl1.x, ctrl1.y, target.x, target.y);
    }

    /**
        Draws a cubic bezier spline to the given point.
    */
    override
    void cubicTo(HaVec2!float ctrl1, HaVec2!float ctrl2, HaVec2!float target) {
        canvasity.bezierCurveTo(ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, target.x, target.y);
    }

    /**
        Begins a new path.
    */
    override
    void closePath() {
        canvasity.closePath();
    }

    /**
        Fills and blits the current outline.

        This should write the final rasterized image to the canvas.
    */
    override
    void blit(HaCanvas canvas) {
        canvasity.fill();
    }

    /**
        Blits a bitmap to the given position.

        This should write the final rasterized image to the canvas.
    */
    override
    void blit(HaCanvas canvas, HaGlyphBitmap bitmap) { }

    /**
        Blits an SVG document

        This should write the final rasterized image to the canvas.
    */
    override
    void blit(HaCanvas canvas, HaGlyphSVG svg) { }


public:

    /**
        Flags indicating the supported rendering formats of the 
        glyph renderer.
    */
    override
    @property HaColorFormat supportedFormats() {
        return HaColorFormat.RGBA32;
    }

    /**
        Flags indicating the capabilities of the renderer.
    */
    override
    @property HaGlyphRendererCapabilityFlags capabilities() {
        return HaGlyphRendererCapabilityFlags.supportsOutlines;
    }

}