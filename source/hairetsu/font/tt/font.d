module hairetsu.font.tt.font;
import hairetsu.font.tt.types;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import nulib.collections;
import numem;

import hairetsu.font.font : HaFont;
import hairetsu.common;

/**
    A TrueType font
*/
class TTFont : SFNTFont {
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
    override @property string type() { return "TrueType"; }

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

