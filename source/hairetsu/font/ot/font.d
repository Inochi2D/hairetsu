module hairetsu.font.ot.font;
import hairetsu.font.ot.types;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import nulib.collections;
import numem;

import hairetsu.font.font : HaFont;
import hairetsu.common;

/**
    OpenType Font Face
*/
class OTFont : SFNTFont {
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
}


