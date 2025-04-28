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
import hairetsu.render.rasterizer;
import hairetsu.glyph;
import hairetsu.common;
import numem;

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

    /**
        Polygonizes the glyph outline.
    */
    HaPolyOutline polygonize(vec2 scale, vec2 offset) {
        HaPolyOutline poutline;
        poutline.scale = scale;
        poutline.offset = offset;

        foreach(HaOutlineOp command; commands) {
            final switch(command.opcode) {

                case HaOutlineOpCode.moveTo:
                    poutline.moveTo(command.target);
                    break;

                case HaOutlineOpCode.lineTo:
                    poutline.lineTo(command.target);
                    break;

                case HaOutlineOpCode.quadTo:
                    poutline.quadTo(command.control1, command.target);
                    break;

                case HaOutlineOpCode.cubicTo:
                    poutline.cubicTo(command.control1, command.control2, command.target);
                    break;

                case HaOutlineOpCode.closePath:
                    poutline.closePath();
                    break;
            }
        }
        poutline.finalize();
        return poutline;
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
