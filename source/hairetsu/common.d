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

import nulib.math.fixed;
import nulib.c.math;

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
struct HaVec2(T) {
@nogc:
    T x = 0;
    T y = 0;


    /**
        Squared length of the vector.
    */
    T sqlength() {
        return cast(T)(
            ((cast(float)x) ^^ 2) + 
            ((cast(float)y) ^^ 2)
        );
    }

    /**
        Length of the vector.
    */
    T length() {
        return cast(T)sqrt(
            ((cast(float)x) ^^ 2) + 
            ((cast(float)y) ^^ 2)
        );
    }

    /**
        Normalizes the vector.
    */
    HaVec2!T normalized() {
        T len = length;
        return HaVec2!T(
            x/len,
            y/len,
        );
    }

    /**
        Gets a perpendicular vector
    */
    HaVec2!T perpendicular() {
        return HaVec2!T(y, cast(T)(-cast(float)x));
    }

    /**
        Binary operators
    */
    auto opBinary(string op)(HaVec2!T vt) {
        return HaVec2!T(
            mixin(q{x: this.x }, op, q{ vt.x, }),
            mixin(q{y: this.y }, op, q{ vt.y, }),
        );
    }

    /// ditto
    auto opBinary(string op)(T other) {
        return HaVec2!T(
            mixin(q{x: this.x }, op, q{ other, }),
            mixin(q{y: this.y }, op, q{ other, }),
        );
    }

    /// ditto
    auto opOpAssign(string op, T)(T value) {
        this = this.opBinary!(op)(value);
        return this;
    }
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