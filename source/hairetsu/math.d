/**
    Hairetsu Math Primitives.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.math;
import nulib.collections.vector;
public import nulib.math : clamp, min, max, copysign, signbit;
public import nulib.c.math;
public import nulib.math.fixed;

/**
    An axis-aligned bounding box
*/
struct HaRect(T) {
@nogc:
    T xMin;
    T xMax;
    T yMin;
    T yMax;

    /**
        X coordinate of the rectangle.
    */
    alias x = xMin;

    /**
        Y coordinate of the rectangle.
    */
    alias y = yMin;

    /**
        The width of the rectangle.
    */
    @property T width() { return xMax-xMin; }
    @property void width(T value) { xMax = xMin + value; }

    /**
        The height of the rectangle.
    */
    @property T height() { return yMax-yMin; }
    @property void height(T value) { yMax = yMin + value; }

    /**
        Wether the rectangle is valid.
    */
    @property bool isValid() { return xMin < xMax && yMin < yMax; }

    /**
        Gets a rectangle that is the intersection of both
        rectangles.
    */
    HaRect!T intersect(HaRect!T other) {
        return HaRect!T(
            xMin > other.xMin ? xMin : other.xMin,
            xMax < other.xMax ? xMax : other.xMax,
            yMin > other.yMin ? yMin : other.yMin,
            yMax < other.yMax ? yMax : other.yMax,
        );
    }
}

/**
    Floating point rect.
*/
alias rect = HaRect!float;

/**
    Floating point rect.
*/
alias recti = HaRect!int;

/**
    A 2-dimensional vector.
*/
struct HaVec2(T) {
@nogc:
    union {
        struct {
            T x = 0;
            T y = 0;
        }
        T[2] data;
    }


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
        Gets the distance between 2 vectors.
    */
    T distanceSquared(HaVec2!T other) {
        T tx = this.x - other.x;
        T ty = this.y - other.y;
        return cast(T)(tx * tx + ty * ty);
    }

    /**
        Gets the distance between 2 vectors.
    */
    T distance(HaVec2!T other) {
        T tx = this.x - other.x;
        T ty = this.y - other.y;
        return cast(T)sqrt(cast(double)(tx * tx + ty * ty));
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
        Gets the midpoint of the line.
    */
    HaVec2!T midpoint(HaVec2!T other) {
        return HaVec2!T(
            cast(T)((this.x + other.x) / 2.0), 
            cast(T)((this.y + other.y) / 2.0)
        );
    }

    /**
        Binary operators
    */
    auto opBinary(string op)(HaVec2!T vt) {
        T vx = mixin(q{ this.x }, op, q{ vt.x });
        T vy = mixin(q{ this.y }, op, q{ vt.y });

        return HaVec2!T(vx, vy);
    }

    /// ditto
    auto opBinary(string op)(T other) {
        T vx = mixin(q{ this.x }, op, q{ other });
        T vy = mixin(q{ this.y }, op, q{ other });

        return HaVec2!T(vx, vy);
    }

    /// ditto
    auto opBinaryRight(string op, L)(L other)
    if (__traits(isScalar, T)) {
        T vx = mixin(q{ other }, op, q{ this.x });
        T vy = mixin(q{ other }, op, q{ this.y });
        
        return HaVec2!T(vx, vy);
    }

    /**
        Assignment operator
    */
    auto opOpAssign(string op, T)(T value) {
        this = this.opBinary!(op)(value);
        return this;
    }
}

/**
    32-bit float 2D Vector
*/
alias vec2 = HaVec2!float;

/**
    32-bit int 2D Vector
*/
alias vec2i = HaVec2!int;

/**
    32-bit fixed Q26.6 2D Vector
*/
alias vec2lf = HaVec2!fixed26_6;

/**
    Represents a 2D line segment.
*/
struct HaLine(T) {
@nogc:
    union {
        struct {
            HaVec2!T p1;
            HaVec2!T p2;
        }
        HaVec2!(T)[2] data;
    }

    /**
        Nudge factor
    */
    HaVec2!T[2] nudge;

    /**
        Adjustment factor
    */
    HaVec2!T[2] adjustment;

    /**
        Params
    */
    HaVec2!T[2] params;

    /**
        Gets the midpoint of the line.
    */
    @property HaVec2!T midpoint() { return p1.midpoint(p2); }

    /**
        Constructor
    */
    this(HaVec2!T start, HaVec2!T end) {
        enum floorNudge = cast(T)0u;
        enum ceilNudge = cast(T)1u;

        this.p1 = start;
        this.p2 = end;

        // Setup nudge factors.
        this.nudge[0].x = end.x >= start.x ? floorNudge : ceilNudge;
        this.adjustment[0].x = cast(T)(end.x >= start.x ? 1.0 : 0.0);
        this.nudge[0].y = end.y >= start.y ? floorNudge : ceilNudge;
        this.adjustment[0].y = cast(T)(end.y >= start.y ? 1.0 : 0.0);
        this.nudge[1].x = end.x > start.x ? ceilNudge : floorNudge;
        this.nudge[1].y = end.y > start.y ? ceilNudge : floorNudge;
        this.params[1] = end - start;
        this.params[0] = HaVec2!T(
            params[1].x == 0.0 ? T.max : (T(1.0) / params[1].x),
            T(1.0) / params[1].y
        );        
    }

    /**
        Repositions the line to fit within the given bounds,
        optionally flips the line.
    */
    void reposition(HaRect!T bounds, bool reverse) {
        HaVec2!T tp1 = reverse ? p2 : p1;
        HaVec2!T tp2 = reverse ? p1 : p2;
        
        tp1.x = cast(T)fabs(cast(double)(p1.x - bounds.xMin));
        tp1.y = cast(T)fabs(cast(double)(p1.y - bounds.yMax));
        tp2.x = cast(T)fabs(cast(double)(p2.x - bounds.xMin));
        tp2.y = cast(T)fabs(cast(double)(p2.y - bounds.yMax));
        this = typeof(this)(tp1, tp2);
    }
}

/**
    32-bit float 2D Vector
*/
alias line = HaLine!float;

/**
    A contour of lines.
*/
alias HaPolyContour = line[];

/**
    Linearly interpolates between $(D a) and $(D b)
*/
T lerp(T)(T a, T b, float t) {
    return a * (1 - t) + b * t;
}

/**
    Quadilaterally interpolates between $(D p0) and $(D p2),
    with $(D p1) as a control point.
*/
T quad(T)(T p0, T p1, T p2, float t) {
    return p0 * ((1-t) ^^ 2) + (p1*2*(1-t)*t) + p2*t^^2;
}

/**
    Interpolates between $(D p0) and $(D p3), using a cubic
    spline with $(D p1) and $(D p2) as control points.
*/
T cubic(T)(T p0, T p1, T p2, T p3, float t) {
    T a = -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3;
    T b = p0 - 2.5 * p1 + 2 * p2 - 0.5 * p3;
    T c = -0.5 * p0 + 0.5 * p2;
    T d = p1;
    
    return a * (t ^^ 3) + b * (t ^^ 2) + c * t + d;
}

/**
    Gets the fractional part of the value.
*/
T fract(T)(T value) {
    return cast(T)(cast(double)value - trunc(cast(double)value));
}
