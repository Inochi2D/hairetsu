/**
    Hairetsu OpenType Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.ot.font;
import hairetsu.font.ot.types;
import hairetsu.font.ot.face;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.font;
import hairetsu.font.face;
import nulib.collections;
import numem;

import hairetsu.common;

/**
    OpenType Font Face
*/
class OTFont : SFNTFont {
protected:
@nogc:
    
    /**
        Implemented by the font to create a new font face.
    */
    override
    HaFontFace onCreateFace(HaFontReader reader) {
        return nogc_new!OTFontFace(this, reader);
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
    override @property string type() { return "OpenType"; }
}


