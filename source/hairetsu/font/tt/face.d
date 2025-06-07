/**
    Hairetsu TrueType Font Face

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.face;
import hairetsu.font.tt.font;
import hairetsu.font.sfnt;
import hairetsu.font;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

import hairetsu.common;

/**
    OpenType CFF/CFF2 font face.
*/
class TTFontFace : SFNTFontFace {
private:
@nogc:

public:

    /**
        Constructs a font face.
    */
    this(Font parent, FontReader reader) {
        super(parent, reader);
    }
}