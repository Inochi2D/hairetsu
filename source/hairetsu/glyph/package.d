/**
    Hairetsu Glyphs

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph;
import hairetsu.raster;
import hairetsu.common;
import numem;

public import hairetsu.glyph.outline;
public import hairetsu.glyph.svg;

/**
    The type of the glyph.
*/
enum GlyphType : uint {

    /**
        No glyph data is loaded.
    */
    none    = 0x00,
    
    /**
        Bitmap Glyph.
    */
    bitmap  = 0x01,

    /**
        A glyph that uses vector outlines.
    */
    outline = 0x02,

    /**
        Glyphs which contain a constrained version of the
        SVG document specification.
    */
    svg     = 0x04,
}

/**
    Position of a glyph
*/
struct GlyphPosition {
    
    /**
        The advance of the glyph.
    */
    vec2lf advance;
    
    /**
        The visual offset of the glyph.
    */
    vec2lf offset;
}

/**
    Glyph Metrics
*/
struct GlyphMetrics {

    /**
        The bounding box of the glyph.
    */
    rect bounds;
    
    /**
        The bearing for the glyph.
    */
    vec2 bearing;
    
    /**
        The advance for the glyph.
    */
    vec2 advance;
}

/**
    A glyph.
*/
struct Glyph {
public:
@nogc:
    
    /**
        The index of the glyph.
    */
    GlyphIndex index;
    
    /**
        The type of the glyph.
    */
    GlyphType type;
    
    /**
        The scaled metrics of the glyph.
    */
    GlyphMetrics metrics;
    
    /**
        The data of the glyph.
    */
    GlyphData data;

    /**
        Sets the bitmap of the glyph
    */
    void setBitmap(GlyphIndex index, GlyphBitmap bitmap) {
        this.reset();

        this.type = GlyphType.bitmap;
        this.index = index;
        this.data.bitmap = bitmap;
    }

    /**
        Sets the outline of the glyph
    */
    void setOutline(GlyphIndex index, GlyphOutline outline) {
        this.reset();

        // Handle no-outline glyphs.
        if (outline.commands.length == 0) {
            this.type = GlyphType.none;
            this.index = index;
            return;
        }

        this.type = GlyphType.outline;
        this.index = index;
        this.data.outline = outline;
    }

    /**
        Sets the SVG of the glyph
    */
    void setSVG(GlyphIndex index, GlyphSVG svg) {
        this.reset();

        this.type = GlyphType.svg;
        this.index = index;
        this.data.svg = svg;
    }

    /**
        Resets the glyph.
    */
    void reset() {
        final switch(type) {
            case GlyphType.outline:
                data.outline.reset();
                break;
                
            case GlyphType.bitmap:
                nogc_delete(data.bitmap);
                break;
                
            case GlyphType.svg:
                data.svg.reset();
                break;
            
            case GlyphType.none:
                return;
        }
        
        this.type = GlyphType.none;
        this.index = 0;
        nogc_zeroinit(data);
    }
    
    /**
        Tries to rasterize the glyph (if possible).

        Returns:
            A bitmap with the rasterized data, if failed
            an empty bitmap will be returned.
    */
    HaBitmap rasterize(bool antialiased = true) {
        final switch(type) {
            
            case GlyphType.outline:

                // Build outline
                HaPolyOutline poutline = data.outline.polygonize(vec2(1, 1), vec2(0, 0));

                // Rasterize
                HaCoverageMask coverage = HaCoverageMask(cast(uint)poutline.bounds.width, cast(uint)poutline.bounds.height);
                coverage.draw(poutline);

                HaBitmap bitmap = HaBitmap(coverage.width, coverage.height, 1);
                if (antialiased) coverage.blitTo!true(bitmap);
                else coverage.blitTo!false(bitmap);

                return bitmap;

            case GlyphType.bitmap:
                return data.bitmap;
            
            case GlyphType.svg:
                return HaBitmap.init; 
            
            case GlyphType.none:
                return HaBitmap.init; 

        }
    }
}

/**
    Alias for backwards compatibility.
*/
alias GlyphBitmap = HaBitmap;

/**
    The different kinds of data that can be stored in a glyph.
*/
union GlyphData {
    GlyphBitmap bitmap;
    GlyphOutline outline;
    GlyphSVG svg;
}