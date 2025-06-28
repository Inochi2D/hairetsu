/**
    Common Hairetsu functionality and data types.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.common;
public import nulib.math.fixed;
public import nulib.text.unicode;
public import nulib.string;
import numem;

public import hairetsu.ot.tag;
public import hairetsu.ot.script;
public import hairetsu.ot.lang;

public import hairetsu.math;

/**
    The 32-bit glyph index in a font.

    A glyph index does not match the unicode codepoint
    that it represents, it is internal to the specific font.
*/
alias GlyphIndex = uint;

/**
    Represents a missing glyph, when rendering this
    glyph should indicate to the user that a character
    is not implemented within the font.
*/
enum GlyphIndex GLYPH_MISSING = 0x0u;

/**
    Allocates an array of the given size.
*/
T[] ha_allocarr(T)(size_t size) @nogc {
    import numem : nogc_initialize;

    T[] buffer;
    buffer = buffer.nu_resize(size);

    nogc_initialize(buffer[0..$]);
    return buffer;
}

/**
    Frees an array
*/
void ha_freearr(T)(ref T[] arr) @nogc {
    static if (is(T : NuRefCounted)) {
        foreach(ref item; arr) {
            item.release();
            item = null;
        }
    }
    
    static if (is(nulib.system.com.unk)) {
        import nulib.system.com.unk : IUnknown;
        
        static if (is(T : IUnknown)) {
            foreach(ref item; arr) {
                item.Release();
                item = null;
            }
        }
    }

    arr = arr.nu_resize(0);
}

/**
    A bitmap containing pixel data.
*/
struct HaBitmap {
@nogc:
    
    /**
        Width of the bitmap
    */
    uint width;
    
    /**
        Height of the bitmap
    */
    uint height;
    
    /**
        Amount of channels in the bitmap
    */
    uint channels;

    /**
        Bytes-per-channel.
    */
    ubyte bpc = 1;
    
    /**
        Raw view into the bitmap.
    */
    ubyte[] data;

    /**
        Constructor
    */
    this(uint width, uint height, uint channels, ubyte bpc = 1) {
        this.width = width;
        this.height = height;
        this.channels = channels;

        // Handle bytes-per-pixel w/ clamping.
        if (bpc == 3) bpc = 4;
        else bpc = cast(ubyte)clamp(bpc, 1, 4);
        this.bpc = bpc;

        this.data = ha_allocarr!ubyte(width*height*channels*bpc);
        this.clear();
    }
    
    /**
        Frees the data associated with the bitmap.
    */
    void free() {
        ha_freearr(data);
    }

    /**
        Clears data from the bitmap
    */
    void clear() {
        this.data[0..$] = 0;
    }

    /**
        Crops the bitmap.
    */
    void crop(uint x0, uint y0, uint x1, uint y1) {
        auto cropped = this.cropped(x0, y0, x1, y1);

        this.free();
        this = cropped;
    }

    /**
        Crops the bitmap.
    */
    HaBitmap cropped(uint x0, uint y0, uint x1, uint y1) {
        if (cast(ptrdiff_t)y1-cast(ptrdiff_t)y0 < 0)
            return HaBitmap.init;
        if (cast(ptrdiff_t)x1-cast(ptrdiff_t)x0 < 0)
            return HaBitmap.init;

        uint newWidth = x1-x0;
        uint newHeight = y1-y0;
        uint pxStride = channels*bpc;
        
        HaBitmap result = HaBitmap(newWidth, newHeight, channels, bpc);
        foreach(y; y0..y1) {
            ubyte[] dstLine = cast(ubyte[])result.scanline(y-y0);
            ubyte[] srcLine = cast(ubyte[])this.scanline(y);

            foreach(x; x0..x1) {
                uint srcBase = (x*pxStride);
                uint dstBase = ((x-x0)*pxStride);
                dstLine[dstBase..dstBase+pxStride] = srcLine[srcBase..srcBase+pxStride];
            }
        }
        return result;
    }

    /**
        Resizes the allocation of the buffer.

        Note:
            This will clear the bitmap of its contents.

        Params:
            width = new width
            height = new height
    */
    void resize(uint width, uint height) {
        size_t newSize = width*height*channels*bpc;
        if (newSize < data.length) {
            this.data = data[0..newSize];
            this.width = width;
            this.height = height;
            this.clear();
            return;
        }

        if (newSize > data.length) {
            this.data = data.nu_resize(newSize);
            this.width = width;
            this.height = height;
            this.clear();
            return;
        }
    }

    /**
        Gets a scanline from the bitmap

        Params:
            y = The scanline to fetch.

        Returns:
            A slice of the scanline.
    */
    void[] scanline(uint y) {
        if (y >= height)
            return null;

        uint stride = (width*channels*bpc);
        uint line = y*stride;
        return cast(void[])data[line..line+stride];
    }

    /**
        Clones the bitmap.

        Returns:
            A new bitmap with the contents of this bitmap
            copied over.
    */
    HaBitmap clone() {
        HaBitmap newbmp = HaBitmap(width, height, channels, bpc);
        newbmp.data[0..$] = this.data[0..$];
        return newbmp;
    }
}
