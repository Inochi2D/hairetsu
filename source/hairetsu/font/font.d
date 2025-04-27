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
        A string describing which outlines are supported
        by the font.
    */
    abstract @property string outlineTypeNames();

    /**
        List of features the font uses.
    */
    abstract @property string[] fontFeatures();

    /**
        Amount of glyphs within the font.
    */
    abstract @property size_t glyphCount();

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