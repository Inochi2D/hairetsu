/**
    Hairetsu Text Shaping Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.shaper;
public import hairetsu.font.face;
public import hairetsu.shaper.buffer;
public import hairetsu.common;
import numem;

/**
    The base interface of text shapers.
*/
abstract
class HaShaper : NuRefCounted {
protected:
@nogc:
public:

    /**
        Shape a buffer of text.

        Params:
            face =      The font face to use for shaping.
            buffer =    The buffer to shape.
    */
    abstract void shape(ref HaFontFace face, ref HaBuffer buffer);
}
