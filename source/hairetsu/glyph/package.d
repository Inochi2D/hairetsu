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
    A glyph.
*/
struct HaGlyph {
private:
@nogc:
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

public:
    
    /*
        Destructor
    */
    ~this() {
        this.reset();
    }
    
    /**
        The index of the glyph
    */
    GlyphIndex index;
    
    /**
        The type of the glyph.
    */
    HaGlyphType type;
    
    /**
        The data of the glyph
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
}

/**
    The different kinds of data that can be stored in a glyph.
*/
union HaGlyphData {
    HaGlyphBitmap bitmap;
    HaGlyphOutline outline;
    HaGlyphSVG svg;
}