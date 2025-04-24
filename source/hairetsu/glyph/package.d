/**
    Hairetsu Glyphs

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph;
import hairetsu.common;
import numem;

public import hairetsu.glyph.raster;
public import hairetsu.glyph.bitmap;
public import hairetsu.glyph.outline;
public import hairetsu.glyph.svg;

/**
    The type of the glyph.
*/
enum HaGlyphType : uint {

    /**
        No glyph data is loaded.
    */
    none,
    
    /**
        Bitmap Glyph.
    */
    bitmap,

    /**
        A glyph that uses vector outlines.
    */
    outline,

    /**
        Glyphs which contain a constrained version of the
        SVG document specification.
    */
    svg
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
struct HaGlyphMetrics {

    /**
        The bounding box of the glyph.
    */
    rect bounds;
    
    /**
        The horizontal bearing for the glyph.
    */
    vec2 bearingH;
    
    /**
        The vertical bearing for the glyph.
    */
    vec2 bearingV;
    
    /**
        The advance for the glyph.
    */
    vec2 advance;
}

/**
    A glyph.
*/
struct HaGlyph {
private:
    
public:
@nogc:
    
    /**
        The index of the glyph.
    */
    GlyphIndex index;
    
    /**
        The type of the glyph.
    */
    HaGlyphType type;
    
    /**
        The scaled metrics of the glyph.
    */
    HaGlyphMetrics metrics;
    
    /**
        The data of the glyph.
    */
    HaGlyphData data;

    /**
        Sets the bitmap of the glyph
    */
    void setBitmap(GlyphIndex index, HaGlyphBitmap bitmap) {
        this.reset();

        this.type = HaGlyphType.bitmap;
        this.index = index;
        this.data.bitmap = bitmap;
    }

    /**
        Sets the outline of the glyph
    */
    void setOutline(GlyphIndex index, HaGlyphOutline outline) {
        this.reset();

        this.type = HaGlyphType.outline;
        this.index = index;
        this.data.outline = outline;
    }

    /**
        Sets the SVG of the glyph
    */
    void setSVG(GlyphIndex index, HaGlyphSVG svg) {
        this.reset();

        this.type = HaGlyphType.svg;
        this.index = index;
        this.data.svg = svg;
    }

    /**
        Resets the glyph.
    */
    void reset() {
        final switch(type) {
            case HaGlyphType.outline:
                data.outline.reset();
                break;
                
            case HaGlyphType.bitmap:
                data.bitmap.reset();
                break;
                
            case HaGlyphType.svg:
                data.svg.reset();
                break;
            
            case HaGlyphType.none:
                return;
        }
        
        this.type = HaGlyphType.none;
        this.index = 0;
        nogc_zeroinit(data);
    }
    
    /**
        Rasterizes the glyph outline, first by turning the outline
        into a series of polylines, then running it through the
        HaRaster rasterizer.
    */
    HaGlyphBitmap rasterizeOutline(uint padding = 4) {
        if (type != HaGlyphType.outline)
            return HaGlyphBitmap.init;

        // Build outline
        HaPolyOutline poutline = data.outline.polygonize(vec2(1, 1), vec2(padding/2, padding/2));

        // Rasterize
        HaRaster raster = HaRaster(cast(uint)poutline.bounds.width+padding, cast(uint)poutline.bounds.height+padding);
        raster.draw(poutline);
        return raster.blit(false);
    }

    /**
        Rasterizes the coverage mask used to generate the outline.
    */
    HaGlyphBitmap rasterizeOutlineMask(uint padding = 4) {
        if (type != HaGlyphType.outline)
            return HaGlyphBitmap.init;

        // Build outline
        HaPolyOutline poutline = data.outline.polygonize(vec2(1, 1), vec2(padding/2, padding/2));

        // Rasterize
        HaRaster raster = HaRaster(cast(uint)poutline.bounds.width+padding, cast(uint)poutline.bounds.height+padding);
        raster.draw(poutline);
        return raster.blit(true);
    }
}

/**
    The different kinds of data that can be stored in a glyph.
*/
union HaGlyphData {
    HaGlyphBitmap bitmap;
    HaGlyphOutline outline;
    HaGlyphSVG svg;
}