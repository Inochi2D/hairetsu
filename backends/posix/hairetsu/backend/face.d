/**
    Hairetsu Posix Fonts

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.backend.face;
import hairetsu.backend.hb;
import hairetsu.backend.ft;

import hairetsu.face;
import hairetsu.font;
import nulib.collections;
import nulib.string;
import numem;

/**
    A POSIX Font Face.
*/
class PosixFontFace : HaFontFace {
@nogc:
private:
    hb_face_t* hb_face;
    FT_Face ft_face;

public:
    
}
