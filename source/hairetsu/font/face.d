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

    // Internal Glyph information.
    HaGlyph glyph_;
    fixed32 pt_     = 18;
    fixed32 dpi_    = 96;
    fixed32 ppem_;
    fixed32 scaleFactor_;

    void updateGlyph(bool rerender = true) {
        ppem_ = pt_ * dpi_ / BASE_TYPOGRAPHIC_DPI;
        scaleFactor_ = ppem / upem;
        
        // Reload and scale metrics.
        glyph_.metrics = this.parent.getMetricsFor(glyph_.index);

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
        The scaling factor needed to turn font units into pixels.
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

    /**
        The dots-per-inch of the font face.
    */
    final @property float dpi() { return cast(float)dpi_; }
    final @property void dpi(float dpi) { this.dpi_ = dpi; this.updateGlyph(); }

    /**
        The point size of the font face
    */
    final @property float pt() { return cast(float)pt_; }
    final @property void pt(float pt) { this.pt_ = pt; this.updateGlyph(); }

    /**
        The pixel size of the font face
    */
    final @property float px() { return cast(float)ppem; }
    final @property void px(float px) {
        this.pt_ = fixed32(px / (cast(float)dpi_ / BASE_TYPOGRAPHIC_DPI));
        this.updateGlyph();
    }

    /*
        Destructor
    */
    ~this() {
        nogc_delete(glyph_);
    }

    /**
        Constructs a font face.
    */
    this(HaFont parent, HaFontReader reader) {
        this.parent_ = parent;
        this.reader_ = reader;
        
        this.updateGlyph(false);
        this.onFaceLoad(reader);
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