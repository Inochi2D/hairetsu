/**
    Hairetsu Glyphs

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.glyph;
import hairetsu.common;

/**
    Types of glyphs stored within a font.
*/
enum GlyphType : uint {
    none        = 0x00,

    // Bitmaps
    sbix        = 0x01,
    ebdt        = 0x02,
    cbdt        = 0x04,
    bitmap      = sbix | ebdt | cbdt,
    
    // Outlines
    trueType    = 0x10,
    cff         = 0x20,
    cff2        = 0x40,
    outline     = trueType | cff | cff2,
    
    // Complex
    svg         = 0x100,
}

/**
    Mask for all glyph types.
*/
enum uint HA_GLYPH_TYPE_MASK_ALL = (GlyphType.max*2)-1;

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
    The base unit of a visual run of text.
*/
struct Glyph {
public:
@nogc:
    
    /**
        The ID of the glyph.
    */
    GlyphIndex id;
    
    /**
        The metrics of the glyph.
    */
    GlyphMetrics metrics;

    /**
        Glyph data.
    */
    GlyphData data;

    /**
        Gets whether the glyph can be drawn.
    */
    pragma(inline, true)
    bool canDraw() { return data.canDraw(); }

    /**
        Gets whether the glyph can be rasterized.
    */
    pragma(inline, true)
    bool canRasterize() { return data.canRasterize(); }

    /**
        Draws the glyph.

        Params:
            scale = Scale factor of glyph while drawing.
            userdata = The user data.
        
        Returns:
            Whether the draw operation succeded.
    */
    bool draw(float scale = 1, void* userdata = null) {
        if (!data.canDraw)
            return false;
        
        return data.drawFunc(data.argHandles, scale, userdata);
    }

    /**
        Rasterizes the glyph.

        Returns:
            A bitmap with the rasterized glyph if successful,
            an uninitialized bitmap otherwise.
    */
    HaBitmap rasterize(float scale = 1, void* userdata = null) {
        if (data.canRasterize)
            return data.rasterizeFunc(data.argHandles, scale, userdata);

        return HaBitmap.init;
    }
}

/**
    Semi-opaque glyph data.
*/
struct GlyphData {
@nogc:

    /**
        Argument handles that gets passed to the rasterizer function.

        These are internal to hairetsu and the font implementations.
    */
    void*[4] argHandles;

    /**
        Function called by the implementation to draw the
        glyph.
    */
    extern(C) bool function(void*[4] dataHandles, float scale, void* userdata) @nogc drawFunc;

    /**
        Function called by the implementation to rasterize the
        glyph.
    */
    extern(C) HaBitmap function(void*[4] dataHandles, float scale, void* userdata) @nogc rasterizeFunc;

    /**
        Gets whether the glyph data can be drawn.
    */
    pragma(inline, true)
    bool canDraw() { return drawFunc !is null; }

    /**
        Gets whether the glyph data can be rasterized.
    */
    pragma(inline, true)
    bool canRasterize() { return rasterizeFunc !is null; }
}

/**
    Callbacks passed to a font to render a glyph.
*/
struct GlyphDrawCallbacks {
@nogc:
    extern(C) void function(float tx, float ty, void* userdata) @nogc moveTo;
    extern(C) void function(float tx, float ty, void* userdata) @nogc lineTo;
    extern(C) void function(float c1x, float c1y, float tx, float ty, void* userdata) @nogc quadTo;
    extern(C) void function(float c1x, float c1y, float c2x, float c2y, float tx, float ty, void* userdata) @nogc cubicTo;
    extern(C) void function(void* userdata) @nogc closePath;
}
