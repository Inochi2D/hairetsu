/**
    Hairetsu Font Face Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.face;
import hairetsu.font.reader;
import hairetsu.font.font;
import hairetsu.glyph;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

import hairetsu.common;

/**
    Style of a font
*/
enum HaFaceStyle : uint {
    
    /**
        Face should be styled regular.
    */
    regular = 0x0,
    
    /**
        Face should be styled italic/oblique.
    */
    italic  = 0x01,
    
    /**
        Face should be styled bold.
    */
    bold    = 0x02
}

/**
    The base typographic DPI value.
*/
enum int BASE_TYPOGRAPHIC_DPI = 72;

/**
    A Font Face Object
*/
abstract
class HaFontFace : NuRefCounted {
private:
@nogc:
    HaFont parent_;
    HaFontReader reader_;
    HaFontMetrics fmetrics_;

    // Internal Glyph information.
    HaGlyph glyph_;
    fixed32 pt_     = 18;
    fixed32 dpi_    = 96;
    fixed32 ppem_;
    fixed32 scaleFactor_;
    bool hinting_;
    bool isHinted_;

    void updateGlyph(bool rerender = true) {
        ppem_ = pt_ * dpi_ / BASE_TYPOGRAPHIC_DPI;
        scaleFactor_ = ppem / upem;
        
        // Reload and scale metrics.
        glyph_.metrics = parent.getMetricsFor(glyph_.index);
        fmetrics_ = parent.fontMetrics();

        // Scale font metrics to pixel grid
        fmetrics_.ascender.x *= scaleFactor_;
        fmetrics_.ascender.y *= scaleFactor_;
        fmetrics_.descender.x *= scaleFactor_;
        fmetrics_.descender.y *= scaleFactor_;
        fmetrics_.lineGap.x *= scaleFactor_;
        fmetrics_.lineGap.y *= scaleFactor_;
        fmetrics_.maxExtent.x *= scaleFactor_;
        fmetrics_.maxExtent.y *= scaleFactor_;
        fmetrics_.maxAdvance.x *= scaleFactor_;
        fmetrics_.maxAdvance.y *= scaleFactor_;

        // Scale to pixel grid
        glyph_.metrics.size.x *= scaleFactor_;
        glyph_.metrics.size.y *= scaleFactor_;
        glyph_.metrics.advance.x *= scaleFactor_;
        glyph_.metrics.advance.y *= scaleFactor_;
        glyph_.metrics.bearingH.x *= scaleFactor_;
        glyph_.metrics.bearingH.y *= scaleFactor_;
        glyph_.metrics.bearingV.x *= scaleFactor_;
        glyph_.metrics.bearingV.y *= scaleFactor_;
        
        if (rerender)
            this.onRenderGlyph(reader_, glyph_);
    }

protected:

    /**
        Implemented by a font face to load a glyph.
    */
    abstract void onRenderGlyph(HaFontReader reader, ref HaGlyph glyph);
    
    /**
        Implemented by the font face to read the face.
    */
    abstract void onFaceLoad(HaFontReader reader);

public:

    /**
        The units-per-EM of the font face.
    */
    final @property uint upem() { return parent_.upem; }

    /**
        The pixels-per-EM of the font face.
    */
    final @property fixed32 ppem() { return ppem_; }

    /**
        The scaling factor needed to turn font units into pixels/dots.
    */
    final @property fixed32 scale() { return scaleFactor_; }

    /**
        The parent font this font face belongs to.
    */
    final @property HaFont parent() { return parent_; }

    /**
        The amount of glyphs in the font.
    */
    final @property size_t glyphCount() { return parent_.glyphCount; }

    final @property bool hinted() { return isHinted_; }

    /**
        Whether hinting is requested enabled for the font face.
    */
    final @property bool hinting() { return hinting_; }
    final @property void hinting(bool hinting) { this.hinting_ = hinting; this.updateGlyph(); }

    /**
        The dots-per-inch of the font face, defaults to 96.

        By default this value is 96, to comply with the reference CSS DPI,
        if you're rendering to paper or the display has DPI information,
        this value needs to be changed.
    */
    final @property float dpi() { return cast(float)dpi_; }
    final @property void dpi(float dpi) { this.dpi_ = dpi; this.updateGlyph(); }

    /**
        The point size of the font face, defaults to 18.

        The point size is a relative size based on the DPI of the surface being
        rendered to.
    */
    final @property float pt() { return cast(float)pt_; }
    final @property void pt(float pt) { this.pt_ = pt; this.updateGlyph(); }

    /**
        The pixel size of the font face, defaults to 24.

        Pixel size is a DPI-independent scaling, no matter how you change the DPI
        the pixel size will not be affected.

        Note:
            If you change the DPI on the fly, you will need to reset the pixel size 
            as it is set relative to the point size.
    */
    final @property float px() { return cast(float)ppem; }
    final @property void px(float px) {
        this.pt_ = fixed32(px / (cast(float)dpi_ / BASE_TYPOGRAPHIC_DPI));
        this.updateGlyph();
    }

    /**
        The scaled font-wide metrics of this face.
    */
    final
    @property HaFontMetrics faceMetrics() { return fmetrics_; }

    /*
        Destructor
    */
    ~this() {
        glyph_.reset();
    }

    /**
        Constructs a font face.
    */
    this(HaFont parent, HaFontReader reader, bool canHint) {
        this.parent_ = parent;
        this.reader_ = reader;
        this.isHinted_ = canHint;
        
        this.onFaceLoad(reader);
        this.updateGlyph(false);
    }

    /**
        Gets the scaled glyph metrics for the given glyph.
        
        Params:
            glyphIdx = Index of the glyph.
        
        Returns:
            The scaled metrics for the given glyph.
    */
    HaGlyphMetrics getMetricsFor(GlyphIndex glyphIdx) {
        
        // Reload and scale metrics.
        auto metrics = this.parent.getMetricsFor(glyphIdx);

        // Scale to pixel grid
        metrics.size.x *= scaleFactor_;
        metrics.size.y *= scaleFactor_;
        metrics.advance.x *= scaleFactor_;
        metrics.advance.y *= scaleFactor_;
        metrics.bearingH.x *= scaleFactor_;
        metrics.bearingH.y *= scaleFactor_;
        metrics.bearingV.x *= scaleFactor_;
        metrics.bearingV.y *= scaleFactor_;
        return metrics;
    }

    /**
        Gets a glyph from the font face.

        Params:
            glyphIdx = Index of the glyph.

        Returns:
            The glyph stored in the font face, if the glyph id 
            is different than the current glyph slot, the 
            glyph will be updated.
    */
    final
    ref HaGlyph getGlyph(GlyphIndex glyphIdx) {
        auto oldIndex = glyph_.index;
        glyph_.index = glyphIdx;

        this.updateGlyph(glyph_.index != oldIndex);
        return glyph_;
    }
}