/**
    Common Hairetsu functionality and data types.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.common;
public import nulib.math.fixed;
public import nulib.text.unicode;
public import nulib.string;

public import hairetsu.ot.tag;
public import hairetsu.ot.script;
public import hairetsu.ot.lang;

@nogc nothrow:

/**
    The 32-bit glyph index in a font.

    A glyph index does not match the unicode codepoint
    that it represents, it is internal to the specific font.
*/
alias GlyphIndex = uint;

/**
    Represents a missing glyph, when rendering this
    glyph should indicate to the user that a character
    is not implemented within the font.
*/
enum GlyphIndex GLYPH_MISSING = 0x0u;

/**
    A 2-dimensional vector.
*/
union HaVec2(T) {
@nogc:
    alias data this;
    struct {
        T x = 0;
        T y = 0;
    }
    T[2] data;
}

/**
    A bounding box
*/
struct HaRect(T) {
@nogc:
    T xMin;
    T xMax;
    T yMin;
    T yMax;
}

/**
    Text reading direction.
*/
enum TextDirection : uint {
    
    /**
        Text is read left-to-right
    */
    leftToRight = 1,
    
    /**
        Text is read right-to-left
    */
    rightToLeft = 2,

    /**
        Text direction is weak, meaning it may change mid-run.
    */
    weak = 4,
}

/**
    The orientation of glyphs in a text segment.
*/
enum TextGravity : uint {
    
    /**
        Southern (upright) gravity.
    */
    south   = 0x00,
    
    /**
        Eastern gravity.
    */
    east    = 0x01,
    
    /**
        Northen (upside-down) gravity.
    */
    north   = 0x02,
    
    /**
        Western gravity.
    */
    west    = 0x03,

    /**
        Scripts will use the natural gravity based on the
        base gravity of the script.
    */
    natural = 0x00,

    /**
        Forces the base gravity to always be used, regardless
        of script.
    */
    strong  = 0x08,

    /**
        For scripts not in their natural direction (eg. Latin in East gravity), 
        choose per-script gravity such that every script respects the line progression.
    */
    line    = 0x0F
}