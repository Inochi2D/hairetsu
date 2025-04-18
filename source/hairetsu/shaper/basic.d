/**
    Hairetsu Basic Shaper

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.shaper.basic;
import hairetsu.shaper;
import hairetsu.common;
import numem;

/**
    A basic built-in text shaper.

    This text shaper is not compatible with complex scripts.
*/
class HaBasicShaper : HaShaper {
@nogc:
public:

    /**
        Shape a buffer of text.

        Params:
            buffer =    The buffer to shape.
    */
    override
    void shape(ref HaBuffer buffer) {

    }
}
