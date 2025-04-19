/**
    Hairetsu TrueType Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.font;
import hairetsu.font.tt.types;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.font;
import hairetsu.font.face;
import nulib.collections;
import numem;

import hairetsu.font.font : HaFont;
import hairetsu.common;

/**
    A TrueType font
*/
class TTFont : SFNTFont {
protected:
@nogc:

    override
    HaFontFace onCreateFace(HaFontReader reader) {
        return null;
    }


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
}

