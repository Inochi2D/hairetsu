/**
    Hairetsu OpenType Font Implementation

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.ot;
import hairetsu.font.ot.types;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt;
import nulib.collections;
import numem;

import hairetsu.font : HaFont, HaFontFace, HaFontReadException;
import hairetsu.common;

/**
    OpenType Font Face
*/
class OTFontFace : SFNTFontFace {
@nogc:
private:

protected:

public:
    
    /**
        Constructs a new font face from a stream.
    */
    this(SFNTFontEntry entry, HaFontReader reader) {
        super(entry, reader);
    }

    /**
        The name of the type of font.
    */
    override @property string type() { return "OpenType"; }

    /**
        Amount of glyphs within font face.
    */
    override @property size_t glyphCount() {
        return 0;
    }

    /**
        Units per EM.
    */
    override @property uint upem() {
        return 0;
    }

    /**
        Fills all of the unicode codepoints that the face supports,
        and writes them to the given set.

        Params:
            cSet = The set to fill.

        Returns:
            The amount of codepoints that were added to the set.
    */
    override uint fillCodepoints(ref set!codepoint cSet) {
        return 0;
    }
}