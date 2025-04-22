/**
    Hairetsu Basic Shaper

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.shaper.basic;
import hairetsu.font.face;
import hairetsu.shaper;
import hairetsu.common;
import numem;

/**
    A basic built-in text shaper.

    This text shaper is not compatible with complex scripts,
    and simply just does a 1-1 translation between character
    and glyph index.
*/
class HaBasicShaper : HaShaper {
public:
@nogc:

    /**
        Shape a buffer of text.

        Params:
            face =      The font face to use for shaping.
            buffer =    The buffer to shape.
    */
    override
    void shape(ref HaFontFace face, ref HaBuffer buffer) {
        codepoint[] glyphs = buffer.take();
        foreach(size_t i, codepoint c; glyphs) {
            glyphs[i] = face.parent.charMap.getGlyphIndex(c);
        }
        buffer.giveShaped(glyphs);
    }
}
