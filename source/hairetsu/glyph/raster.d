/**
    Port of the fontdue outline rasterizer.

    MIT License

    Copyright (c) 2019 Joe C (mooman219)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    Copyright:
        Copyright © 2019, Joe C (mooman219)
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 https://github.com/mooman219/fontdue/blob/master/LICENSE-MIT, MIT License)
    Authors:   Luna Nielsen, fontdue Contributors
*/
module hairetsu.glyph.raster;
import hairetsu.glyph;
import hairetsu.math;
import numem;

version(Have_intel_intrinsics) import inteli;

/**
    A rasterized coverage mask
*/
struct HaRaster {
private:
@nogc:

    version(Have_intel_intrinsics)
    void blitToSIMD(ref ubyte[] bitmap) {

        // TODO: SIMD Optimize this.
        this.blitToSimple(bitmap);
    }

    void blitToSimple(ref ubyte[] bitmap) {

        float covHeight = 0.0;
        foreach(i; 0..coverage.length) {
            covHeight += coverage[i];
            bitmap[i] = cast(ubyte)clamp(fabs(covHeight) * 255.9, 0.0, 255.0);
        }
    }

    void add(uint i, float covHeight, float midX) {
        auto m = covHeight * midX;
        coverage[i] += covHeight - m;
        coverage[i+1] += m;
    }

    void lineV(line line, vec2 p0, vec2 p1) {
        vec2 start = vec2(
            trunc(cast(float)cast(int)p0.x - cast(int)line.nudge[0].x),
            trunc(cast(float)cast(int)p0.y - cast(int)line.nudge[0].y)
        );
        vec2 end = vec2(
            trunc(cast(float)(cast(int)p1.x - cast(int)line.nudge[1].x)),
            trunc(cast(float)(cast(int)p1.y - cast(int)line.nudge[1].y))
        );

        float targetY = (start.y + line.adjustment[0].y);
        float sy = copysign(1.0f, p1.y - p0.y);
        float prevY = p0.y;
        
        int index = cast(int)(start.x + start.y * width);
        int incY = cast(int)(copysign(cast(float)width, sy));
        int dist = cast(int)(fabs(start.x - end.y));
        float midX = fract(p0.x);
        while(dist > 0) {
            dist--;
            this.add(index, prevY, midX);
            index += incY;
            prevY = targetY;
            targetY += sy;
        }
        this.add(cast(int)(end.x + end.y * cast(float)width), prevY- p0.y, midX);
    }

public:
    
    /**
        Width of the raster.
    */
    uint width;
    
    /**
        Height of the raster.
    */
    uint height;
    
    /**
        Coverage mask of the raster.
    */
    float[] coverage;

    /*
        Destructor
    */
    ~this() {
        this.width = 0;
        this.height = 0;
        coverage = coverage.nu_resize(0, 4);
    }

    /**
        Constructs a new raster.
    */
    this(HaPolyOutline outline, vec2 scale, vec2 offset) {
        assert(outline.bounds.isValid);

        this.width = cast(uint)ceil(outline.bounds.width*scale.x);
        this.height = cast(uint)ceil(outline.bounds.height*scale.y);

        // Aligned allocation to allow for SIMD.
        coverage = coverage.nu_resize(width*height, 4);
        foreach(contour; outline.contours) {
            foreach(line vline; contour) {
                this.lineV(vline, vline.p1 * scale + offset, vline.p2 * scale + offset);
            }
        }
    }

    void blitTo(ref ubyte[] bitmap) {
        assert(bitmap.length >= coverage.length);

        version(Have_intel_intrinsics)
            this.blitToSIMD(bitmap);
        else
            this.blitToSimple(bitmap);
    }
}


