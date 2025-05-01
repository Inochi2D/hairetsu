/**
    Hairetsu Coverage Mask Generator
    
    ACKNOWLEDGEMENTS:
        This code has taken inspiration from multiple sources, canvas_ity, fontdue, 
        dplug:canvas, dg2d and others.
        As such, i'd like to acknowledge the creators of the prior work I base my code on, 
        such as Joe C (mooman219), Andrew Kensler, Chris Jones, Guillaume Piolat and more.
        While this code started out as a fontdue port, it eventually was scrapped in favor
        of me learning from these implementations and attempting my own. Nontheless, the 
        inspiration I've taken from these other projects and their renderers warrants
        acknowledgement.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 https://github.com/mooman219/fontdue/blob/master/LICENSE-MIT, MIT License)
    Authors:   Luna Nielsen
*/
module hairetsu.render.rasterizer.coverage;
import hairetsu.render.rasterizer.outline;
import hairetsu.math;
import numem;

version(Have_intel_intrinsics) import inteli;
import hairetsu.common;

/**
    A signed coverage mask.
*/
struct HaCoverageMask {
private:
@nogc:

    // Adds a coverage delta to the coverage mask.
    void add(vec2 p, float delta) {
        auto i = cast(int)(p.x + p.y * width);
        if (i+1 >= coverage.length) return;

        coverage[i] += delta;
    }

    // Adds a line segment to the coverage mask.
    void addLine(haline line, vec2 offset) {
        enum float epsilon = 2.0e-5f;

        vec2 p1 = line.p1+offset;
        vec2 p2 = line.p2+offset;
        if (abs(p2.y - p1.y) < epsilon) {
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

public:

    /**
        The built-in padding added to the coverage mask.

        This is needed to prevent outline spills with the
        current algorithm.
    */
    enum uint MASK_PADDING = 4;

    /**
        The built-in pixel offset added to the coverage mask.

        This is needed to prevent outline spills with the
        current algorithm.
    */
    enum vec2 MASK_OFFSET = vec2(MASK_PADDING/2, MASK_PADDING/2);
    
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
        this.coverage = coverage.nu_resize(0);
    }

    /**
        Creates a new coverage mask.

        Params:
            width = width of the coverage mask in pixels.
            height = height of the coverage mask in pixels.
    */
    this(uint width, uint height) {
        this.width = width+MASK_PADDING;
        this.height = height+MASK_PADDING;

        this.coverage = coverage.nu_resize(this.width * this.height);
        this.clear();
    }

    /**
        Postblit
    */
    this(this) {
        this.width = width;
        this.height = height;
        this.coverage = coverage.nu_dup();
    }

    /**
        Draws the outline into the coverage mask, do note that it does
        NOT clear the current contents of the coverage mask.

        Params:
            outline = The outline to render.

        See_Also:
            $(D HaCoverageMask.clear)
    */
    void draw(ref HaPolyOutline outline) {
        if (!outline.bounds.isValid)
            return;
        
        foreach(line; outline.lines) {
            this.addLine(line, MASK_OFFSET);
        }
    }

    /**
        Draws a single line into the coverage mask.
    */
    void draw(haline line) {
        this.addLine(line, MASK_OFFSET);
    }

    /**
        Clears the coverage mask.
    */
    void clear() {
        this.coverage[0..$] = 0.0f;
    }
    
    /**
        Flattens the coverage mask.
        
        This function essentially converts the signed coverage mask into
        an unsigned floating point mask in the range of 0..1.
    */
    void flatten() {
        float[] line;
        line = line.nu_resize(width);

        foreach(y; 0..height) {
            size_t lineY = y * width;
            float delta = 0;

            foreach(x; 0..width) {
                delta += coverage[lineY+x];
                line[lineY+x] = min(abs(delta), 1.0);
            }

            // Update the coverage mask with the new flattened values.
            coverage[lineY..lineY+width] = line[0..width];
        }

        // Free the temporary buffer
        line = line.nu_resize(0);
    }

    /**
        Blits a single scanline to the given buffer.
        This is all that's needed for basic glyph rendering.

        Params:
            scanline =  The scanline to blit the coverage mask to.
            channels =  The channel count of the scanline.
            y =         The scanline in the coverage mask to blit.
    */
    void blitScanlineTo(bool antialias)(ubyte[] scanline, uint channels, uint y) {
        if (y >= height)
            return;
        
        float delta = 0;
        foreach(x; 0..width) {
            size_t bi = (x*channels);
            size_t ci = (y * width) + x;

            // Skip if we're running past the bitmap length.
            if (bi+channels >= scanline.length)
                continue;
            
            delta += coverage[ci];
            static if (antialias) {
                scanline[bi..bi+channels] = cast(ubyte)clamp(abs(delta) * 255.0f, 0.0, 255.0);
            } else {
                scanline[bi..bi+channels] = abs(delta) > 0.50 ? 255 : 0;
            }
        }
    }

    /**
        Blits the coverage mask directly to a bitmap.
        This is all that's needed for basic glyph rendering.

        Params:
            bitmap = The bitmap to blit the coverage mask to.
    */
    void blitTo(bool antialias)(ref HaBitmap bitmap) {
        foreach(y; 0..height) {
            this.blitScanlineTo!antialias(cast(ubyte[])bitmap.scanline(y), bitmap.channels, y);
        }
    }
}