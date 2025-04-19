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
    A Font Face Object
*/
abstract
class HaFontFace : NuRefCounted {
private:
@nogc:
    HaFont parent_;
    HaFontReader reader_;
    HaGlyph glyph_;

protected:

    /**
        Implemented by a font face to load a glyph.
    */
    abstract void onUpdateGlyph(HaFontReader reader, ref HaGlyph glyph);
    
    /**
        Implemented by the font face to read the face.
    */
    abstract void onFaceLoad(HaFontReader reader);

public:

    /**
        The pixels-per-EM of the face.

        Note:
            The glyph needs to be updated if you
            change this value.
    */
    HaVec2!ushort ppem;
    
    /**
        The scale of the font face.

        Note:
            The glyph needs to be updated if you
            change this value.
    */
    HaVec2!fixed32 scale;

    /**
        The parent font this font face belongs to.
    */
    final @property HaFont parent() { return parent_; }

    /**
        The amount of glyphs in the font.
    */
    final @property size_t glyphCount() { return parent_.glyphCount; }

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
        if (glyph_.index != glyphIdx) {
            glyph_.index = glyphIdx;
            this.onUpdateGlyph(reader_, glyph_);
        }
        return glyph_;
    }
}