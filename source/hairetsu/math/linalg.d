/**
    Hairetsu Linear Algebra

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.math.linalg;
import nulib.collections.vector;
public import nulib.math.fixed;
public import nulib.math;

/**
    A 2D point
*/
alias vec2 = Vec2Impl!float;

/**
    An integral 2D point
*/
alias vec2i = Vec2Impl!int;

/**
    An unsigned integral 2D point
*/
alias vec2u = Vec2Impl!int;

/**
    A 2D point.
*/
struct Vec2Impl(T) {
@nogc:
    alias data this;
    union {
        struct {

            /**
                X coordinate.
            */
            T x;
            
            /**
                Y coordinate.
            */
            T y;
        }
        T[2] data;
    }

    /**
        Value Type
    */
    alias vt = T;

    /**
        Zero vector
    */
    enum zero = Vec2Impl!T(0, 0);
    
    /**
        One vector
    */
    enum one = Vec2Impl!T(1, 1);

    /**
        Squared length of the vector.
    */
    @property
    T sqlength() {
        return cast(T)(
            ((cast(float)x) ^^ 2) + 
            ((cast(float)y) ^^ 2)
        );
    }

    /**
        Length of the vector.
    */
    @property
    T length() {
        return cast(T).sqrt(
            ((cast(float)x) ^^ 2) + 
            ((cast(float)y) ^^ 2)
        );
    }
    
    /**
        Whether the vector contains finite values.
    */
    @property
    bool isFinite() {
        static if (__traits(isFloating, T))
            return .isFinite(x) && .isFinite(y);
        else
            return true;
    }

    /**
        Gets the distance between 2 vectors.
    */
    T distanceSquared(Vec2Impl!T other) {
        T tx = this.x - other.x;
        T ty = this.y - other.y;
        return cast(T)(tx * tx + ty * ty);
    }

    /**
        Gets the distance between 2 vectors.
    */
    T distance(Vec2Impl!T other) {
        T tx = this.x - other.x;
        T ty = this.y - other.y;
        return cast(T).sqrt(cast(double)(tx * tx + ty * ty));
    }

    /**
        Calculates the product between two vectors.
    */
    T dot(Vec2Impl!T other) {
        return (this.x * other.x) + (this.y * other.y);
    }

    /**
        Normalizes the vector.
    */
    Vec2Impl!T normalized() {
        T len = length;
        return Vec2Impl!T(
            x/len,
            y/len,
        );
    }

    /**
        Gets a perpendicular vector
    */
    Vec2Impl!T perpendicular() {
        return Vec2Impl!T(y, cast(T)(-cast(float)x));
    }

    /**
        Gets the midpoint of the line.
    */
    Vec2Impl!T midpoint(Vec2Impl!T other) {
        return Vec2Impl!T(
            cast(T)((this.x + other.x) / 2.0), 
            cast(T)((this.y + other.y) / 2.0)
        );
    }

    /**
        Binary operators
    */
    auto opBinary(string op)(Vec2Impl!T vt) {
        T vx = mixin(q{ this.x }, op, q{ vt.x });
        T vy = mixin(q{ this.y }, op, q{ vt.y });

        return Vec2Impl!T(vx, vy);
    }

    /// ditto
    auto opBinary(string op)(T other) {
        T vx = mixin(q{ this.x }, op, q{ other });
        T vy = mixin(q{ this.y }, op, q{ other });

        return Vec2Impl!T(vx, vy);
    }

    /// ditto
    auto opBinaryRight(string op, L)(L other)
    if (__traits(isScalar, T)) {
        T vx = mixin(q{ other }, op, q{ this.x });
        T vy = mixin(q{ other }, op, q{ this.y });
        
        return Vec2Impl!T(vx, vy);
    }

    /**
        Assignment operator
    */
    auto opOpAssign(string op, T)(T value) {
        this = this.opBinary!(op)(value);
        return this;
    }

    /**
        Equality operator
    */
    bool opEquals(R)(const R other) const {
        return (this.x == other.x && this.y == other.y);
    }
}

enum isVec2(T) = is(T == Vec2Impl!U, U...);

/**
    An unsigned integral 2D point
*/
alias mat2 = Mat2Impl!float;

struct Mat2Impl(T) {
@nogc:
    T[2][2] matrix = [[0, 0], [0, 0]];

    /**
        Identity matrix.
    */
    static Mat2Impl identity = Mat2Impl([[cast(T)1, cast(T)0], [cast(T)0, cast(T)1]]);
    
    /**
        Creates a scale matrix.
    */
    static Mat2Impl scale(T x, T y) { return Mat2Impl([[x, 0], [0, y]]); }
    
    /**
        Creates a shear matrix.
    */
    static Mat2Impl shear(T x, T y) { return Mat2Impl([[1, -x], [-y, 1]]); }

    /**
        Binary operators
    */
    auto opBinary(string op = "*")(Mat2Impl!T other) {
        Mat2Impl!T result;
        static foreach(r; 0..2) {
            static foreach(c; 0..2) {
                result.matrix[r][c] += this.matrix[r][c] * other.matrix[r][c];
            }
        }
        return result;
    }
    
    /**
        Binary operators
    */
    auto opBinary(string op = "*")(Vec2Impl!T other) {
        Vec2Impl!T result = Vec2Impl!T(0, 0);
        static foreach(r; 0..2) {
            static foreach(c; 0..2) {
                result.data[r] += this.matrix[r][c] * other.data[c];
            }
        }
        return result;
    }
    
    /**
        Binary operators
    */
    auto opBinaryRight(string op = "*")(Vec2Impl!T other) {
        Vec2Impl!T result = Vec2Impl!T(0, 0);
        static foreach(r; 0..2) {
            static foreach(c; 0..2) {
                result.data[r] += other.data[c] * this.matrix[r][c];
            }
        }
        return result;
    }
}

enum isMat2(T) = is(T == Mat2Impl!U, U...);

/**
    Truncates the values of the vector.
*/
auto trunc(T)(T value) if (isVec2!T) {
    import nlmath = nulib.math;
    return T(
        cast(T.vt)nlmath.trunc(cast(double)value.x), 
        cast(T.vt)nlmath.trunc(cast(double)value.y)
    );
}

/**
    Gets a vector with both axis made absolute.
*/
auto abs(T)(T value) if (isVec2!T) {
    import nlmath = nulib.math;
    return T(
        T.vt(nlmath.abs!double(cast(double)value.x)), 
        T.vt(nlmath.abs!double(cast(double)value.y))
    );
}

/**
    Performs integer subtraction between this vector
    and another.
*/
auto isub(T, Y)(T value, Y other) if (isVec2!T && isVec2!Y) {
    return T(
        T.vt(cast(int)value.x - cast(int)other.x),
        T.vt(cast(int)value.y - cast(int)other.y),
    );
}

/**
    A 2D line segment.
*/
alias line = LineImpl!float;

/**
    Represents a 2D line segment.
*/
struct LineImpl(T) {
@nogc:
    union {
        struct {
            Vec2Impl!T p1;
            Vec2Impl!T p2;
        }
        Vec2Impl!(T)[2] data;
    }

    /**
        Nudge factor
    */
    Vec2Impl!T[2] nudge;

    /**
        Adjustment factor for initial.
    */
    Vec2Impl!T adjustment;

    /**
        Signed area of the line
    */
    Vec2Impl!T area;
    
    /**
        Line delta based off the signed area.
    */
    Vec2Impl!T delta;

    /**
        The midpoint of the line.
    */
    @property Vec2Impl!T midpoint() { return p1.midpoint(p2); }

    /**
        The ccw normal for the line
    */
    @property Vec2Impl!T normal() {
        return Vec2Impl!T(-(p2.y - p1.y), (p2.x - p1.x)).normalized;
    }

    /**
        Constructor
    */
    this(Vec2Impl!T start, Vec2Impl!T end) {
        enum floorNudge = cast(T)0u;
        enum ceilNudge = cast(T)1u;

        this.p1 = start;
        this.p2 = end;

        // Setup nudge factors.
        this.nudge[0].x = end.x >= start.x ? floorNudge : ceilNudge;
        this.nudge[0].y = end.y >= start.y ? floorNudge : ceilNudge;
        this.nudge[1].x = end.x > start.x ? ceilNudge : floorNudge;
        this.nudge[1].y = end.y > start.y ? ceilNudge : floorNudge;

        // Setup adjustments
        this.adjustment.x = cast(T)(end.x >= start.x ? 1.0 : 0.0);
        this.adjustment.y = cast(T)(end.y >= start.y ? 1.0 : 0.0);

        // Setup deltas
        this.area = end - start;
        this.delta = Vec2Impl!T(
            cast(T)(1.0 / cast(float)area.x),
            cast(T)(1.0 / cast(float)area.y),
        );
    }

    /**
        Gets the slope at the given point
    */
    Vec2Impl!T slope() {
        return Vec2Impl!T(
            (p2.x - p1.x) / (p2.y - p1.y),
            (p2.y - p1.y) / (p2.x - p1.x)
        );
    }
}

/**
    Floating point rect.
*/
alias rect = RectImpl!float;

/**
    Floating point rect.
*/
alias recti = RectImpl!int;

/**
    A 2D rectangle
*/
struct RectImpl(T) {
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
    RectImpl!T intersect(RectImpl!T other) {
        return RectImpl!T(
            xMin > other.xMin ? xMin : other.xMin,
            xMax < other.xMax ? xMax : other.xMax,
            yMin > other.yMin ? yMin : other.yMin,
            yMax < other.yMax ? yMax : other.yMax,
        );
    }
}
