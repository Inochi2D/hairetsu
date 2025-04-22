/**
    Hairetsu Glyph Outline Implementation Details

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph.outline;
import nulib.collections.vector;
import hairetsu.glyph;
import hairetsu.common;
import numem;
import hairetsu.glyph.raster;

/**
    An outline stored in a glyph.
*/
struct HaGlyphOutline {
private:
@nogc:

    // Helper which pushes an outline operation to the command list.
    pragma(inline, true)
    void pushOp(HaOutlineOp op) {
        commands = commands.nu_resize(commands.length+1);
        commands[$-1] = op;
    }
public:

    /**
        Winding rule to use.
    */
    HaWindingRule windingRule = HaWindingRule.nonZero;

    /**
        Command stream
    */
    HaOutlineOp[] commands;

    /**
        Resets the outline.
    */
    void reset() {
        commands = commands.nu_resize(0);
    }

    /**
        Pushes a moveTo command to the outline.
    */
    void moveTo(vec2 to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.moveTo, 
            target: to
        ));
    }

    /**
        Pushes a lineTo command to the outline.
    */
    void lineTo(vec2 to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.lineTo, 
            target: to
        ));
    }

    /**
        Pushes a quadTo command to the outline.
    */
    void quadTo(vec2 control, vec2 to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.quadTo, 
            control1: control,
            target: to, 
        ));
    }

    /**
        Pushes a cubicTo command to the outline.
    */
    void cubicTo(vec2 control1, vec2 control2, vec2 to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.cubicTo, 
            control1: control1, 
            control2: control2,
            target: to, 
        ));
    }

    /**
        Pushes a closePath command to the outline.
    */
    void closePath() {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.closePath
        ));
    }
}

/**
    Opcodes for an outline operation.
*/
enum HaOutlineOpCode : uint {
    
    /**
        Move to given coordinates.
    */
    moveTo,
    
    /**
        Draw a line to given coordinates.
    */
    lineTo,
    
    /**
        Draw a quadratic spline to the given coordinates,
        using $(D control1) as the control point.
    */
    quadTo,
    
    /**
        Draw a cubic spline to the given coordinates,
        using $(D control1) and $(D control2) as the control points.
    */
    cubicTo,
    
    /**
        Closes the current path.
    */
    closePath
}

/**
    Winding rule which should be applied during rendering.
*/
enum HaWindingRule : uint {
    
    /**
        Even-odd winding rule.
    */
    evenOdd,
    
    /**
        Non-zero winding rule.
    */
    nonZero
}

/**
    A single outline operation.
*/
struct HaOutlineOp {
    
    /**
        The opcode of the line instruction
    */
    HaOutlineOpCode opcode;
    
    /**
        The target coordinates of the instruction
    */
    vec2 target;
    
    /**
        The first control point for the instruction
    */
    vec2 control1;
    
    /**
        The second control point for the instruction
    */
    vec2 control2;
}

/**
    An outline made out of polylines, better suited for rendering.
*/
struct HaPolyOutline {
private:
@nogc:
    enum segmentCount = 16;
    enum inf = float.infinity;

    rect aabb = rect(-inf, inf, -inf, inf); 
    vec2 pen = vec2(0, 0);

    /**
        Gets the current contour being written to.
    */
    ref HaPolyContour currentContour() {
        if (contours.length == 0)
            this.nextContour();
        
        return contours[$-1];
    }

    /**
        Adds a new contour.
    */
    void nextContour() {
        contours = contours.nu_resize(contours.length+1);
    }

    /**
        Grows the size of the current contour.
    */
    void growContour(size_t by) {
        currentContour = currentContour.nu_resize(currentContour.length+by);
    }

    /**
        Moves the pen to the given position
    */
    void movePen(vec2 target) {

        // Resize X axis bounds
        if (pen.x < aabb.xMin)
            aabb.xMin = pen.x;
        if (pen.x > aabb.xMax)
            aabb.xMax = pen.x;

        // Resize Y axis.
        if (pen.y < aabb.yMin)
            aabb.yMin = pen.y;
        if (pen.y > aabb.yMax)
            aabb.yMax = pen.y;

        pen = target;
    }

public:

    /**
        The list of contours.
    */
    HaPolyContour[] contours;

    /**
        The bounds of the outline
    */
    @property rect bounds() { return aabb; }

    // Destructor
    ~this() { this.reset(); }

    /**
        Moves to the given location.
    */
    void moveTo(vec2 target) {
        if (currentContour.length > 0)
            nextContour();

        pen = target;
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void lineTo(vec2 target) {
        this.growContour(1);
        currentContour[$-1] = line(pen, target);

        pen = target;
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void quadTo(vec2 ctrl1, vec2 target) {
        this.growContour(1);

        float step = 1.0/cast(float)segmentCount;
        vec2 pos;
        foreach(i; 1..segmentCount) {
            float t = cast(float)i*step;
            this.lineTo(quad(pen, ctrl1, target, t));
        }
        pen = target;
    }

    /**
        Adds a line segment extending from the previous line
        segment.
    */
    void cubicTo(vec2 ctrl1, vec2 ctrl2, vec2 target) {
        this.growContour(1);

        float step = 1.0/cast(float)segmentCount;
        vec2 pos;
        foreach(i; 1..segmentCount) {
            float t = cast(float)i*step;
            this.lineTo(cubic(pen, ctrl1, ctrl2, target, t));
        }
        pen = target;
    }

    /**
        Closes the current path and starts a new subpath.
    */
    void closePath() {
        if (currentContour.length == 0)
            return;
        
        this.growContour(1);

        auto contourStart = currentContour[0].p1;
        currentContour[$-1] = line(pen, contourStart);

        pen = contourStart;
        this.nextContour();
    }

    /**
        Reset the contours by freeing them.
    */
    void reset() {
        if (contours.length > 0) {
            foreach(ref contour; contours) {
                contour = contour.nu_resize(0);
            }

            contours = contours.nu_resize(0);
        }

        nogc_initialize(this);
    }
    
    /**
        Rasterizes the poly outline
    */
    HaRaster rasterize(vec2 scale, vec2 offset) {
        return HaRaster(this, scale, offset);
    }
}
