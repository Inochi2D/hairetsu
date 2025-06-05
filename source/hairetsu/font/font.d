/**
    Hairetsu Font Object Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.font;
import hairetsu.font.reader;
import hairetsu.font.cmap;
import hairetsu.font.face;
import hairetsu.glyph;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

import hairetsu.common;

/**
    Types of glyphs stored within the font.
*/
enum HaGlyphStoreType {
    trueType = 0x01,
    CFF      = 0x02,
    CFF2     = 0x04,
    SVG      = 0x08,
    bitmap   = 0x10,
}

/**
    Mask for all glyph types.
*/
enum uint HA_GLYPH_TYPE_MASK_ALL = (HaGlyphStoreType.max*2)-1;

/**
    A Font Object
*/
abstract
class HaFont : NuRefCounted {
@nogc:
private:
    HaFontReader reader;
    uint index_;

protected:
    
    /**
        Implemented by the font to read the font.
    */
    abstract void onFontLoad(HaFontReader reader);
    
    /**
        Implemented by the font to create a new font face.
    */
    abstract HaFontFace onCreateFace(HaFontReader reader);
    
public:

    /**
        Index of face within font file.
    */
    final @property size_t index() { return index_; }

    /**
        Constructs a new font face from a stream.
    */
    this(uint index, HaFontReader reader) {
        this.index_ = index;
        this.reader = reader;
        this.onFontLoad(reader);
    }

    /**
        The postscript name of the font face.
    */
    abstract @property string name();

    /**
        The font family of the font face.
    */
    abstract @property string family();

    /**
        The sub font family of the font face.
    */
    abstract @property string subfamily();

    /**
        The name of the type of font.
    */
    abstract @property string type();

    /**
        Amount of glyphs within the font.
    */
    abstract @property uint glyphCount();

    /**
        The types of glyphs are supported by the font.
    */
    abstract @property HaGlyphStoreType glyphTypes();

    /**
        A string describing which types of glyphs are supported
        by the font.
    */
    final
    @property string glyphTypeNames() { return __ha_glyph_type_names[glyphTypes]; }

    /**
        List of features the font uses.
    */
    abstract @property string[] fontFeatures();

    /**
        The character map for the font.
    */
    abstract @property HaCharMap charMap();

    /**
        Font-wide shared metrics.
    */
    abstract @property HaFontMetrics fontMetrics();

    /**
        Units per EM.
    */
    abstract @property uint upem();

    /**
        The lowest recommended pixels-per-EM for readability.
    */
    abstract @property uint lowestPPEM();

    /**
        The bounding box of the font.
    */
    abstract @property HaRect!int boundingBox();

    /**
        Gets the vertical metrics for the given glyph.

        Params:
            glyph =     Index of the glyph to get the metrics for.

        Returns:
            The metrics for the glyph in **font units**.

        Note:
            It is recommended you cache the value returned by
            this function.
    */
    abstract HaGlyphMetrics getMetricsFor(GlyphIndex glyph);

    /**
        Creates a face from the font.

        Returns:
            A font face.
    */
    final
    HaFontFace createFace() {
        return this.onCreateFace(reader);
    }
}

/**
    Metrics shared between glyphs in a font.
*/
struct HaFontMetrics {
@nogc:

    /**
        The global ascenders for the font.
    */
    vec2 ascender;
    
    /**
        The global descenders for the font.
    */
    vec2 descender;
    
    /**
        The global line gaps for the font.
    */
    vec2 lineGap;
    
    /**
        The global max extents for glyphs.
    */
    vec2 maxExtent;
    
    /**
        The global max advances for glyphs.
    */
    vec2 maxAdvance;
}



// LUT containing the different outline type names.
private __gshared const string[HA_GLYPH_TYPE_MASK_ALL] __ha_glyph_type_names = genOutlineTypeNames!();
private template genOutlineTypeNames() {
    string genGlyphMaskName(uint offset) {
        import std.array : join;
        string[] elements;
        if (offset & HaGlyphStoreType.trueType)
            elements ~= "TrueType";
        if (offset & HaGlyphStoreType.CFF)
            elements ~= "CFF";
        if (offset & HaGlyphStoreType.CFF2)
            elements ~= "CFF2";
        if (offset & HaGlyphStoreType.SVG)
            elements ~= "SVG";
        if (offset & HaGlyphStoreType.bitmap)
            elements ~= "Bitmap";
        
        return "["~elements.join(", ")~"]";
    }

    string[HA_GLYPH_TYPE_MASK_ALL] genOutlineTypeNamesImpl() {
        string[HA_GLYPH_TYPE_MASK_ALL] strings;
        static foreach(i; 0..HA_GLYPH_TYPE_MASK_ALL) {
            strings[i] = genGlyphMaskName(i);
        }
        return strings;
    }

    enum string[HA_GLYPH_TYPE_MASK_ALL] genOutlineTypeNames = genOutlineTypeNamesImpl();
}