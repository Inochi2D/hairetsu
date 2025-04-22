/**
    Hairetsu Glyph Outline Implementation Details

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.glyph.outline;
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
    void moveTo(HaVec2!float to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.moveTo, 
            target: to
        ));
    }

    /**
        Pushes a lineTo command to the outline.
    */
    void lineTo(HaVec2!float to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.lineTo, 
            target: to
        ));
    }

    /**
        Pushes a quadTo command to the outline.
    */
    void quadTo(HaVec2!float control, HaVec2!float to) {
        pushOp(HaOutlineOp(
            opcode: HaOutlineOpCode.quadTo, 
            control1: control,
            target: to, 
        ));
    }

    /**
        Pushes a cubicTo command to the outline.
    */
    void cubicTo(HaVec2!float control1, HaVec2!float control2, HaVec2!float to) {
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
    HaVec2!float target;
    
    /**
        The first control point for the instruction
    */
    HaVec2!float control1;
    
    /**
        The second control point for the instruction
    */
    HaVec2!float control2;
}