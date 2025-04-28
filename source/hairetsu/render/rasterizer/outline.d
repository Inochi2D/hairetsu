/**
    Hairetsu Polygon Outlines

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.render.rasterizer.outline;
import nulib.collections.vector;
import hairetsu.common;
import numem;

/**
    An outline made out of polylines, better suited for rendering.
*/
struct HaPolyOutline {
private:
@nogc:
    enum bmax = float.infinity;

    // Segments to split beziers into.
    enum segmentCount = 24;

    bool shouldReverse = false;
    float area = 0;
    rect aabb = rect(bmax, -bmax, bmax, -bmax); 
    vec2 start = vec2(0, 0);
    vec2 pen = vec2(0, 0);


    //
    //      Internal handling
    //

    void recalcBounds(vec2 pos) {

        // Resize X axis bounds
        if (pos.x < aabb.xMin)
            aabb.xMin = pos.x;
        if (pos.x > aabb.xMax)
            aabb.xMax = pos.x;

        // Resize Y axis.
        if (pos.y < aabb.yMin)
            aabb.yMin = pos.y;
        if (pos.y > aabb.yMax)
            aabb.yMax = pos.y;
    }

    void push(vec2 p1, vec2 p2, bool move = true) {
        this.lines ~= haline(p1 * scale + offset, p2 * scale + offset);
        this.recalcBounds(p1);
        this.recalcBounds(p2);

        if (move) this.pen = p2;
    }

public:
    ~this() { this.reset(); }

    /**
        Lines
    */
    vector!haline lines;

    /**
        Offset of the outline
    */
    vec2 offset;
    
    /**
        Scale of the outline
    */
    vec2 scale;

    /**
        The bounds of the outline
    */
    @property rect bounds() { return aabb; }

    /**
        Reset the contours by freeing them.
    */
    void reset() {
        lines.clear();
        nogc_initialize(this);
    }

    /**
        Moves to the given location.
    */
    void moveTo(vec2 target) {
        this.closePath();

        this.start = target;
        this.pen = target;
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void lineTo(vec2 target) {
        this.push(pen, target);
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void quadTo(vec2 ctrl1, vec2 target) {
        float step = 1.0/cast(float)segmentCount;
        vec2 qstart = pen;
        foreach(i; 1..segmentCount) {
            float t = cast(float)i*step;
            this.lineTo(quad(qstart, ctrl1, target, t));
        }
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void cubicTo(vec2 ctrl1, vec2 ctrl2, vec2 target) {
        float step = 1.0/cast(float)segmentCount;
        vec2 qstart = pen;

        foreach(i; 1..segmentCount+1) {
            float t = cast(float)i*step;
            this.lineTo(cubic(qstart, ctrl1, ctrl2, target, t));
        }
    }

    /**
        Closes the current path and starts a new subpath.
    */
    void closePath() {
        if (start != pen)
            this.push(pen, start);
        
        this.start = pen;
    }

    /**
        Finalizes the outline.
    */
    void finalize() {
        if (this.lines.empty) {
            this.aabb = rect.init;
            return;
        }

        // Close any unclosed paths.
        this.closePath();

        vec2 baseOffset = vec2(
            -this.aabb.xMin,
            -this.aabb.yMax + this.aabb.height
        );

        foreach(ref line; lines) {
            line.p1 += baseOffset;
            line.p2 += baseOffset;
        }
    }
}
