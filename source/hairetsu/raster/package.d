/**
    Hairetsu Rasterization framework
*/
module hairetsu.raster;
import hairetsu.glyph.outline;
import hairetsu.common;
import numem;

public import hairetsu.raster.coverage;

/**
    Rasterizer 
*/
abstract
class HaRasterizer : NuRefCounted {
private:
    HaBitmap bitmap;

public:

    /**
        Width of the rasterizers internal store in pixels.
    */
    final
    @property uint width() { return bitmap.width; }

    /**
        Height of the rasterizers internal store in pixels.
    */
    final
    @property uint height() { return bitmap.height; }

    /**
        Constructs a new rasterizer
    */
    this(uint width, uint height, uint channels) {
        this.bitmap = HaBitmap(width, height, channels);
    }

    /**
        Draws a polygonized outline to the rasterizer's buffer.
    */
    abstract void draw(ref HaPolyOutline outline, vec2 offset);

    /**
        Draws an outline to the rasterizer's buffer.
    */
    abstract void draw(ref GlyphOutline outline, vec2 offset);

    /**
        Clears the rasterizer's buffer.
    */
    void clear() {
        bitmap.clear();
    }

    /**
        Copies the rasterizer's bitmap
    */
    void copyTo(ref HaBitmap sourceBitmap) {
        foreach(y; 0..sourceBitmap.height) {
            if (y >= bitmap.height)
                break;

            ubyte[] source = cast(ubyte[])sourceBitmap.scanline(y);
            ubyte[] target = cast(ubyte[])bitmap.scanline(y);
            size_t toCopy = min(source.length, target.length);
            target[0..toCopy] = source[0..toCopy];
        }
    }
}
