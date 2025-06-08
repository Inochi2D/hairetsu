/**
    Hairetsu Glyphs

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.glyph;
import hairetsu.font.font;
import hairetsu.ot.tables.glyf;
import hairetsu.common;
import numem;

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
    any = bitmap | outline | svg
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

    /**
        The overall scale applied to the glyph.
    */
    float scale = 1;
}

/**
    The base unit of a visual run of text.
*/
struct Glyph {
private:
@nogc:
    GlyphData data;

public:

    /**
        The font that owns the glyph and its data.
    */
    Font font;

    /**
        The ID of the glyph.
    */
    GlyphIndex id;
    
    /**
        The metrics of the glyph.
    */
    GlyphMetrics metrics;

    /**
        Sets the active data of the glyph.
    */
    void setData(string svg) {
        this.data.type = GlyphType.svg;
        this.data.svg = svg;
    }

    /**
        Sets the active data of the glyph.
    */
    void setData(GlyfRecord* glyf) {
        this.data.type = GlyphType.trueType;
        this.data.glyf = glyf;
    }

    /**
        The raw data stored in the glyph.
    */
    @property GlyphData rawData() { return data; }

    /**
        Whether the glyph has any data.
    */
    @property bool hasData() { return data.type != GlyphType.none; }

    /**
        The SVG data for the glyph (if present).
    */
    @property string svg() { return data.type == GlyphType.svg ? data.svg : null; }

    /**
        The Hairetsu flattened path for the glyph (if present).
    */
    @property Path path() {
        Path path;
        this.drawOutline(GlyphDrawCallbacks.createForPath(), metrics.scale, &path);
        return path;
    }

    /**
        Draws outline using the callbacks
    */
    void drawOutline(GlyphDrawCallbacks callbacks, float scale, void* userdata) {
        switch(data.type) {
            case GlyphType.trueType:
                return data.glyf.drawWith(callbacks, scale, userdata);
            
            default:
                return;
        }
    }

    /**
        Rasterizes the glyph using internal Hairetsu mechanisms.
    */
    HaBitmap rasterize(bool antialias = true) {

        switch(data.type) {
            case GlyphType.trueType:
            case GlyphType.cff:
            case GlyphType.cff2:
                import hairetsu.raster.coverage : HaCoverageMask;

                // Generate path.
                Path p = this.path();
                if (p.hasPath) {
                    p.finalize();

                    HaCoverageMask covMask = HaCoverageMask(cast(uint)p.bounds.width, cast(uint)p.bounds.height);
                    HaBitmap bitmap = HaBitmap(covMask.width, covMask.height, 1, 1);
                    
                    covMask.draw(p);
                    covMask.blitTo(bitmap, antialias);
                    
                    p.free();
                    covMask.free();
                    return bitmap;
                }
                p.free();
                return HaBitmap.init;
            
            case GlyphType.sbix:
            case GlyphType.ebdt:
            case GlyphType.cbdt:
                return data.bitmap.clone();

            default:
                return HaBitmap.init;

        }
    }

    /**
        Copies the glyph to the heap.
    */
    Glyph* copyToHeap() {
        Glyph* glyph = nogc_new!Glyph;
        *glyph = this;
        return glyph;
    }
}

/**
    Opaque data that hairetsu backends fill out as they see fit.
*/
struct GlyphData {
@nogc:

    /**
        The type of the data.
    */
    GlyphType type;

    union {

        /**
            SVG document
        */
        string svg;

        /**
            Glyf Record
        */
        GlyfRecord* glyf;

        /**
            Bitmap
        */
        HaBitmap bitmap;

        /**
            32 bytes of untyped data.
        */
        void[32] data;
    }
}

/**
    Callbacks passed to a font to draw a monochrome glyph.
*/
struct GlyphDrawCallbacks {
@nogc:
    extern(C) void function(float tx, float ty, void* userdata) @nogc moveTo;
    extern(C) void function(float tx, float ty, void* userdata) @nogc lineTo;
    extern(C) void function(float c1x, float c1y, float tx, float ty, void* userdata) @nogc quadTo;
    extern(C) void function(float c1x, float c1y, float c2x, float c2y, float tx, float ty, void* userdata) @nogc cubicTo;
    extern(C) void function(void* userdata) @nogc closePath;

    /**
        Creates a callback struct that fills out a Path primitive
        built in to hairetsu.
    */
    static GlyphDrawCallbacks createForPath() @nogc {
        return GlyphDrawCallbacks(
            moveTo: &_ha_path_move_to_func,
            lineTo: &_ha_path_line_to_func,
            quadTo: &_ha_path_quad_to_func,
            cubicTo: &_ha_path_cubic_to_func,
            closePath: &_ha_path_close_path_func,
        );
    }
}

// Internal drawing functions
private extern(C) {
    void _ha_path_move_to_func(float tx, float ty, void* userdata) @nogc {
        Path* path = cast(Path*)userdata;
        path.moveTo(vec2(tx, ty));
    }

    void _ha_path_line_to_func(float tx, float ty, void* userdata) @nogc {
        Path* path = cast(Path*)userdata;
        path.lineTo(vec2(tx, ty));
    }

    void _ha_path_quad_to_func(float c1x, float c1y, float tx, float ty, void* userdata) @nogc {
        Path* path = cast(Path*)userdata;
        path.quadTo(vec2(c1x, c1y), vec2(tx, ty));
    }

    void _ha_path_cubic_to_func(float c1x, float c1y, float c2x, float c2y, float tx, float ty, void* userdata) @nogc {
        Path* path = cast(Path*)userdata;
        path.cubicTo(vec2(c1x, c1y), vec2(c2x, c2y), vec2(tx, ty));
    }

    void _ha_path_close_path_func(void* userdata) @nogc {
        Path* path = cast(Path*)userdata;
        path.closePath();
    }
}
