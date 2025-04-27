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
    void blitToSIMD(ref ubyte[] bitmap, bool mask) {

        // TODO: SIMD Optimize this.
        this.blitToSimple(bitmap, mask);
    }

    void blitToSimple(ref ubyte[] bitmap, bool mask) {
        foreach(y; 0..height) {
            float delta = 0;
            foreach(x; 0..width) {
                size_t i = x + y * width;
                if (i >= bitmap.length)
                    continue;

                if (mask) delta = coverage[i]+0.5;
                else delta += coverage[i];

                if (antialias)
                    bitmap[i] = cast(ubyte)clamp(fabs(delta) * 255.0f, 0.0, 255.0);
                else
                    bitmap[i] = fabs(delta) > 0.01 ? 255 : 0;
            }
        }
    }

    void add(vec2 p, float delta, float mid) {
        auto i = cast(int)(p.x + p.y * width);
        if (i+1 >= coverage.length) return;
       
        float m = delta * mid;
        coverage[i] += delta - m;
        coverage[i+1] += m;
    }

    void add(vec2 p, float delta) {
        auto i = cast(int)(p.x + p.y * width);
        if (i+1 >= coverage.length) return;

        coverage[i] += delta;
    }

    // Debug function to draw the outline as just ugly lines.
    // this is here in case things break again.
    debug
    void drawLine(haline line, vec2 scale, vec2 offset) {
        vec2 pos = (line.p1 * scale + offset).trunc();
        vec2 end = (line.p2 * scale + offset).trunc();
        vec2 dir = vec2(
            fabs(end.x - pos.x),
            -fabs(end.y - pos.y)
        );
        vec2 sign = vec2(
            copysign(1.0, end.x - pos.x), 
            copysign(1.0, end.y - pos.y)
        );
        float error = dir.x + dir.y;

        while (true) {
            this.add(pos, 1);
            float e2 = 2 * error;

            if (e2 >= dir.y) {
                if (pos.x == end.x) break;

                error = error + dir.y;
                pos.x += sign.x;
            } else {
                if (pos.y == end.y) break;

                error = error + dir.y;
                pos.y += sign.y;
            }
        }
    }

    void addLine(haline line, vec2 offset) {
        enum float epsilon = 2.0e-5f;

        vec2 p1 = line.p1+offset;
        vec2 p2 = line.p2+offset;
        if (fabs(p2.y - p1.y) < epsilon) {
            return;
        }
        
        // Start and endpoints of the line, snapped to pixels.
        float sign = copysign(1.0f, line.p2.y - line.p1.y);
        bool flip = p1.x > p2.x;
        vec2 from = (flip ? p2 : p1);
        vec2 to   = (flip ? p1 : p2);

        vec2 pixel = from.trunc();
        vec2 now = from;

        // Sign, which determines which direction to move across
        // the line.
        vec2 corner = pixel + vec2(1.0f, to.y > from.y ? 1.0f : 0.0f);
        vec2 slope = haline(from, to).slope();
        
        // Deltas to move on each axis.
        bool xneg = to.x - from.x < epsilon;
        vec2 nextX = xneg ? to : vec2(corner.x, now.y + (corner.x - now.x) * slope.y);
        vec2 nextY = vec2(now.x + (corner.y - now.y) * slope.x, corner.y);

        // Snap to to to prevent attempts to write out of bounds.
        if ((from.y < to.y && to.y < nextY.y) || 
            (from.y > to.y && to.y > nextY.y))
                nextY = to;
        

        // We essentially do a souped up bresenham's line algorithm
        // first by iterating over X, then Y.
        // using the direction the line is moving to determine whether
        // it closes or opens the outline.
        //
        // This is essentially a signed coverage mask, complying with
        // the even-odd rule.
        float strip;
        float mid;
        float area;
        vec2 delta = vec2(1.0, to.y > from.y ? 1.0f : -1.0f);
        do {
            float carry = 0.0;
            while(nextX.x < nextY.x) {
                strip = clamp((nextX.y - now.y) * delta.y, 0.0, 1.0);
                mid = (nextX.x + now.x) * 0.5f;
                area = (mid - pixel.x) * strip;
                this.add(pixel, (carry + strip - area) * sign);

                carry = area;
                now = nextX;
                nextX.x += 1;
                nextX.y = (nextX.x - from.x) * slope.y + from.y;
                pixel.x += delta.x;
            }

            // End of strip
            strip = clamp((nextY.y - now.y) * delta.y, 0.0, 1.0);
            mid = (nextY.x + now.x) * 0.5f;
            area = (mid - pixel.x) * strip;
            this.add(pixel, (carry + strip - area) * sign);
            this.add(vec2(pixel.x + 1, pixel.y), area * sign);

            now = nextY;
            nextY.y += delta.y;
            nextY.x = (nextY.y - from.y) * slope.x + from.x;
            pixel.y += delta.y;

            // Snap to to to prevent attempts to write out of bounds.
            if ((from.y < to.y && to.y < nextY.y) || 
                (from.y > to.y && to.y > nextY.y))
                    nextY = to;
            
        } while(now.y != to.y);
    }

    void blitTo(ref ubyte[] bitmap) {
        assert(bitmap.length >= coverage.length);

        version(Have_intel_intrinsics)
            this.blitToSIMD(bitmap, false);
        else
            this.blitToSimple(bitmap, false);
    }

    void blitMaskTo(ref ubyte[] bitmap) {
        assert(bitmap.length >= coverage.length);

        version(Have_intel_intrinsics)
            this.blitToSIMD(bitmap, true);
        else
            this.blitToSimple(bitmap, true);
    }

    void clear() {
        this.width = 0;
        this.height = 0;
        coverage = coverage.nu_resize(0);
    }

public:

    /**
        Whether to enable anti aliasing (default on)
    */
    bool antialias = true;
    
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
        this.clear();
    }

    /**
        Creates a new raster
    */
    this(uint width, uint height) {
        this.width = width+4;
        this.height = height+4;
        this.coverage = coverage.nu_resize(this.width * this.height);
    }

    /**
        Constructs a new raster.
    */
    void draw(ref HaPolyOutline outline) {
        if (!outline.bounds.isValid)
            return;
        
        this.coverage[0..$] = 0.0f;
        foreach(line; outline.lines) {
            this.addLine(line, vec2(2, 2));
        }
    }

    /**
        Blits the raster data to a glyph bitmap.
    */
    HaGlyphBitmap blit() {
        HaGlyphBitmap bitmap;
        bitmap.width = width;
        bitmap.height = height;
        bitmap.channels = 1;
        bitmap.data = bitmap.data.nu_resize(width * height);
        
        this.blitTo(bitmap.data);
        this.clear();
        return bitmap;
    }

    /**
        Blits the raster data to a glyph bitmap.
    */
    HaGlyphBitmap blitMask() {
        HaGlyphBitmap bitmap;
        bitmap.width = width;
        bitmap.height = height;
        bitmap.channels = 1;
        bitmap.data = bitmap.data.nu_resize(width * height);
        
        this.blitMaskTo(bitmap.data);
        this.clear();
        return bitmap;
    }
}
