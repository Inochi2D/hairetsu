/**
    Hairetsu Glyphs

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.math.path;
import nulib.collections.vector;
import hairetsu.math;
import hairetsu.common;

/**
    A logical path; a series of lines which makes up shapes.

    Higher level primitves such as splines are decomposed into
    simple line segments.
*/
struct Path {
private:
@nogc:

    /// Default value for the axis aligned bounding box.
    enum aabbDefault = rect(float.infinity, -float.infinity, float.infinity, -float.infinity);

    //
    //      Internal handling
    //

    void recalcBounds(vec2 pos) {

        // Resize X axis bounds
        if (pos.x < bounds.xMin)
            bounds.xMin = pos.x;
        if (pos.x > bounds.xMax)
            bounds.xMax = pos.x;

        // Resize Y axis.
        if (pos.y < bounds.yMin)
            bounds.yMin = pos.y;
        if (pos.y > bounds.yMax)
            bounds.yMax = pos.y;
    }

    void push(vec2 p1, vec2 p2, bool move = true) {
        this.subpath.segments ~= line(p1, p2);
        this.recalcBounds(p1);
        this.recalcBounds(p2);

        if (move) this.cursor = p2;
    }

public:
    
    /**
        Subpaths contained within the path.
    */
    vector!Subpath subpaths;
    
    /**
        Bounds of the path.
    */
    rect bounds = aabbDefault;
    
    /**
        Cursor position.
    */
    vec2 cursor;

    /**
        How many times to subdivide curves.
    */
    uint curveSubdivisions = 24;

    /**
        Gets the current active subpath.
    */
    final
    @property ref Subpath subpath() {
        if (this.subpaths.length > 0)
            return this.subpaths[$-1];

        this.subpaths ~= Subpath();
        return this.subpaths[$-1];
    }

    // Destructor
    ~this() { this.clear(); }

    /**
        Begins a path
    */
    void moveTo(vec2 pos) {
        this.closePath();
        this.cursor = pos;
    }

    /**
        Draws a line to the given point
    */
    void lineTo(vec2 target) {
        this.push(cursor, target);
    }

    /**
        Draws a quadratic curve to the given target.
    */
    void quadTo(vec2 ctrl1, vec2 target) {
        float step = 1.0/cast(float)curveSubdivisions;
        vec2 qstart = cursor;

        foreach(i; 1..curveSubdivisions) {
            float t = cast(float)i*step;
            this.lineTo(quad(qstart, ctrl1, target, t));
        }
    }

    /**
        Draws a cubic spline to the given target.
    */
    void cubicTo(vec2 ctrl1, vec2 ctrl2, vec2 target) {
        float step = 1.0/cast(float)curveSubdivisions;
        vec2 qstart = cursor;

        foreach(i; 1..curveSubdivisions) {
            float t = cast(float)i*step;
            this.lineTo(cubic(qstart, ctrl1, ctrl2, target, t));
        }
    }

    /**
        Closes the current subpath and starts a new one.
    */
    void closePath() {

        // No need to close a path that does not have any
        // data.
        if (this.subpath.length == 0)
            return;
        
        vec2 start = subpaths[$-1].start;
        vec2 end = subpaths[$-1].end;
        this.push(end, start);

        this.subpaths ~= Subpath();
    }

    /**
        Clears all subpaths from the path.
    */
    void clear() {

        // Free subpaths.
        foreach(ref subpath; this.subpaths) {
            subpath.clear();
        }
        this.subpaths.clear();
        
        // Reset state.
        this.cursor = vec2.zero;
        this.bounds = aabbDefault;
    }

    /**
        Makes a copy of the path
    */
    Path clone() {
        Path npath;
        foreach(ref Subpath subpath; this.subpaths[]) {
            npath.subpaths ~= subpath.clone();
        }
        return npath;
    }
}

/**
    A mathematical description of lines and curves to be drawn.
*/
struct Subpath {
private:
    vector!line segments;

public:
@nogc:

    /**
        A list of line segments in the subpath.
    */
    @property line[] lines() {
        return segments[];
    }

    /**
        The length of the subpath (in line segments).
    */
    @property size_t length() { 
        return segments.length; 
    }

    /**
        The start of the path.
    */
    @property vec2 start() {
        if (segments.length == 0)
            return vec2.init;
        
        return segments[0].p1;
    }

    /**
        The end point of the path.
    */
    @property vec2 end() {
        if (segments.length == 0)
            return vec2.init;
        
        return segments[$-1].p2;
    }

    /**
        Whether the subpath is closed.
    */
    @property bool isClosed() {
        vec2 sp = start;
        vec2 ep = end;

        if (!sp.isFinite || !ep.isFinite)
            return false;
        return sp == ep;
    }
    
    /**
        Pushes a line segment to the subpath.
    */
    void push(line lineSegment) {
        this.segments ~= lineSegment;
    }

    /**
        Clears the subpath of line segments.
    */
    void clear() {
        this.segments.clear();
    }

    /**
        Clones the subpath.
    
        Returns:
            A cloned version of the subpath,
            the caller is responsible for clearing/freeing it.
    */
    Subpath clone() {
        Subpath newPath;
        newPath.segments ~= this.lines;
        return newPath;
    }
}
