/**
    The Unified Hairetsu Bytecode Virtual Machine

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.vm.vm;
import nulib.collections.vector;
import nulib.math.fixed;
import hairetsu.font.vm;
import hairetsu.math;
import nulib.math;
import numem;

/**
    A native subroutine which may be executed by the virtual machine.
*/
alias HaNativeSubroutine = bool function(HaVirtualMachine vm, void* userData) @nogc nothrow;

/**
    A function called when a MoveToABS instruction is encountered.
*/
alias HaMoveToAbsFunc = bool function(vec2 target, void* userData) @nogc nothrow;

/**
    A function called when a MoveTo instruction is encountered.
*/
alias HaMoveToFunc = bool function(vec2 target, void* userData) @nogc nothrow;

/**
    A function called when a LineTo instruction is encountered.
*/
alias HaLineToFunc = bool function(vec2 target, void* userData) @nogc nothrow;

/**
    A function called when a QuadTo instruction is encountered.
*/
alias HaQuadToFunc = bool function(vec2 ctrl, vec2 target, void* userData) @nogc nothrow;

/**
    A function called when a CubicTo instruction is encountered.
*/
alias HaCubicToFunc = bool function(vec2 ctrl1, vec2 ctrl2, vec2 target, void* userData) @nogc nothrow;

/**
    A function called when a ClosePath instruction is encountered.
*/
alias HaClosePathFunc = bool function(void* userData) @nogc nothrow;

/**
    A Unified Hairetsu Bytecode Virtual Machine
*/
class HaVirtualMachine : NuRefCounted {
private:
@nogc:
    HaExecutionContext* exec;
    vector!uint stack;
    vector!HaSubroutine subroutines; 
    uint[255] persistentStore;

    //
    //      HELPERS
    //

    /**
        Storage for subroutines.
    */
    struct HaSubroutine {
    @nogc:
        bool isBytecode;
        union {
            ubyte[] bytecode;
            HaNativeSubroutine nativeRoutine;
        }
    }

    bool mathOp(string op, T)() {
        if (stack.length < 2)
            return false;
        
        T b = this.pop!T();
        T a = this.pop!T();
        this.push!T(mixin("a "~op~" b"));
        return true;
    }

protected:

    /**
        Runs a single instruction in the execution context.
    */
    bool runOne() {
        HaOpCode opcode;
        if (!exec.read(opcode))
            return false;

        switch(opcode) {
            case HA_PUSH_F32:

                float value;
                if (!exec.read(value))
                    return false;

                this.push!float(value);
                return true;
            
            case HA_PUSH_I32:

                int value;
                if (!exec.read(value))
                    return false;

                this.push!int(value);
                return true;
            
            case HA_PEEK:

                int stackOffset;
                if (!exec.read(stackOffset))
                    return false;

                this.push!uint(this.peek!uint(stackOffset));
                return true;
            
            case HA_POP:
                cast(void)this.pop!uint();
                return true;
            
            case HA_PS_GET:
                uint slot;
                if (!exec.read(slot))
                    return false;
                
                this.push!uint(this.psGet!uint(cast(ubyte)slot));
                return true;
            
            case HA_PS_SET:
                uint slot;
                if (!exec.read(slot))
                    return false;
                
                uint value = this.pop!uint();
                this.psSet!uint(cast(ubyte)slot, value);
                return true;

            // Basic math operators.
            case HA_ADDI: return mathOp!("+", int);
            case HA_ADDF: return mathOp!("+", float);
            case HA_SUBI: return mathOp!("-", int);
            case HA_SUBF: return mathOp!("-", float);
            case HA_MULI: return mathOp!("*", int);
            case HA_MULF: return mathOp!("*", float);
            case HA_DIVI: return mathOp!("/", int);
            case HA_DIVF: return mathOp!("/", float);
            case HA_MODI: return mathOp!("%", int);
            case HA_MODF: return mathOp!("%", float);
            
            case HA_FTOI:

                int stackOffset;
                if (!exec.read(stackOffset))
                    return false;

                this.push!int(cast(int)this.peek!float(stackOffset));
                return true;
            
            case HA_ITOF:

                int stackOffset;
                if (!exec.read(stackOffset))
                    return false;

                this.push!float(cast(float)this.peek!int(stackOffset));
                return true;
            
            case HA_CMPI:
                int b = this.pop!int();
                int a = this.pop!int();
                this.push!int(clamp(a-b, -1, 1));
                return true;
            
            case HA_CMPF:
                float b = this.pop!float();
                float a = this.pop!float();
                this.push!int(cast(int)clamp(a-b, -1, 1));
                return true;
            
            case HA_NOT:
                int cmp = this.pop!int();
                this.push!int(-cmp);
                return true;
            
            case HA_MIXF:
                float t = this.pop!float();
                float b = this.pop!float();
                float a = this.pop!float();
                this.push!float(lerp(a, b, t));
                return true;
            
            case HA_JE:

                uint address;
                if (!exec.read(address))
                    return false;

                int cmp = this.pop!int();
                if (cmp == 0)
                    return exec.jump(address);
                return true;
            
            case HA_JL:
                uint address;
                if (!exec.read(address))
                    return false;

                int cmp = this.pop!int();
                if (cmp == -1)
                    return exec.jump(address);
                return true;
            
            case HA_JLE:
                uint address;
                if (!exec.read(address))
                    return false;

                int cmp = this.pop!int();
                if (cmp <= 0)
                    return exec.jump(address);
                return true;
            
            case HA_JG:
                uint address;
                if (!exec.read(address))
                    return false;

                int cmp = this.pop!int();
                if (cmp == 1)
                    return exec.jump(address);
                return true;
            
            case HA_JGE:
                uint address;
                if (!exec.read(address))
                    return false;

                int cmp = this.pop!int();
                if (cmp >= 0)
                    return exec.jump(address);
                return true;

            case HA_JSR:
                int sbid;
                if (!exec.read(sbid))
                    return false;
                
                // Early exit: subroutine not found.
                if (sbid >= subroutines.length)
                    return false;

                auto sub = subroutines[sbid];
                if (sub.isBytecode) {
                    exec = exec.push(sub.bytecode);
                    return true;
                }
                return sub.nativeRoutine(this, userData);

            case HA_RET:
                exec = exec.pop();
                return true;
            
            case HA_MOVE_TO_ABS:
                if (!&moveToAbs)
                    return false;
                
                float y = this.pop!float();
                float x = this.pop!float();
                return moveToAbs(vec2(x, y), userData);
            
            case HA_MOVE_TO:
                if (!&moveTo)
                    return false;
                
                float y = this.pop!float();
                float x = this.pop!float();
                return moveTo(vec2(x, y), userData);
            
            case HA_LINE_TO:
                if (!&lineTo)
                    return false;
                
                float y = this.pop!float();
                float x = this.pop!float();
                return lineTo(vec2(x, y), userData);
            
            case HA_QUAD_TO:
                if (!&quadTo)
                    return false;
                
                float y = this.pop!float();
                float x = this.pop!float();
                float cy = this.pop!float();
                float cx = this.pop!float();
                return quadTo(vec2(cx, cy), vec2(x, y), userData);
            
            case HA_CUBIC_TO:
                if (!&cubicTo)
                    return false;
                
                float y = this.pop!float();
                float x = this.pop!float();
                float c2y = this.pop!float();
                float c2x = this.pop!float();
                float c1y = this.pop!float();
                float c1x = this.pop!float();
                return cubicTo(vec2(c1x, c1y), vec2(c2x, c2y), vec2(x, y), userData);
            case HA_CLOSE_PATH:
                if (!&closePath)
                    return false;

                return closePath(userData);


            // Default do nothing.
            default: return false;
        }
    }

    void destroyExecutionState() {
        auto cexec = exec;

        // Cleanup.
        while(cexec.prev)
            cexec = cexec.pop();
    }

public:

    /**
        User Data to pass to callbacks.
    */
    void* userData;

    /**
        Called when a MoveToAbs instruction is encountered.
    */
    HaMoveToAbsFunc moveToAbs = (pos, data) => false;

    /**
        Called when a MoveTo instruction is encountered.
    */
    HaMoveToFunc moveTo = (pos, data) => false;

    /**
        Called when a LineTo instruction is encountered.
    */
    HaLineToFunc lineTo = (pos, data) => false;

    /**
        Called when a QuadTo instruction is encountered.
    */
    HaQuadToFunc quadTo = (ctrl, pos, data) => false;

    /**
        Called when a CubicTo instruction is encountered.
    */
    HaCubicToFunc cubicTo = (ctrl1, ctrl2, pos, data) => false;

    /**
        Called when a CubicTo instruction is encountered.
    */
    HaClosePathFunc closePath = (data) => false;

    /**
        Destructor
    */
    ~this() {
        foreach(ref subroutine; subroutines) {
            if (subroutine.isBytecode) 
                nogc_delete(subroutine.bytecode);
        }

        subroutines.clear();
    }

    //
    //      PERSISTENT STORE
    //

    /**
        Gets value from the persistent store.
    */
    T psGet(T)(ubyte slot) if (T.sizeof == 4) {
        return reinterpret_cast!T(persistentStore[slot]);
    }

    /**
        Sets value from the persistent store.
    */
    void psSet(T)(ubyte slot, T value) if (T.sizeof == 4) {
        persistentStore[slot] = reinterpret_cast!T(value);
    }

    //
    //      STACK MANAGMENT.
    //

    /**
        Pushes an element onto the virtual machine stack.
    */
    void push(T)(T item) if (T.sizeof <= 4) {
        static if (__traits(isFloating, T))
            stack ~= reinterpret_cast!uint(item);
        else static if (isFixed!T)
            stack ~= item.data;
        else static if (__traits(isUnsigned, T))
            stack ~= cast(uint)item;
        else
            stack ~= cast(uint)reinterpret_cast!ulong(cast(long)item);
    }

    /**
        Pops an element from the stack.
    */
    T peek(T)(int offset, T defaultValue = T.init) if (T.sizeof <= 4) {
        ptrdiff_t element = cast(ptrdiff_t)stack.length+offset;

        // Return default value if no more stack elements.
        if (element < 0 || element >= stack.length)
            return defaultValue;

        uint value = stack[element];
        static if (__traits(isFloating, T))
            return cast(T)reinterpret_cast!float(value);
        else static if (isFixed!T) 
            return T.fromData(value);
        else static if (__traits(isUnsigned, T))
            return cast(T)value;
        else 
            return cast(T)reinterpret_cast!int(value);
    }

    /**
        Pops an element from the stack.
    */
    T pop(T)(T defaultValue = T.init) if (T.sizeof <= 4) {
        scope(exit) stack.popBack();

        // Return default value if no more stack elements.
        if (stack.length == 0)
            return defaultValue;

        uint value = *stack.back();
        static if (__traits(isFloating, T))
            return cast(T)reinterpret_cast!float(value);
        else static if (isFixed!T) 
            return T.fromData(value);
        else static if (__traits(isUnsigned, T))
            return cast(T)value;
        else 
            return cast(T)reinterpret_cast!int(value);
    }


    //
    //          EXECUTION STATE MANAGMENT.
    //

    /**
        Sets a bytecode subroutine within the virtual machine.
    */
    void setSubroutine(int id, ubyte[] bytecode) {
        if (id >= subroutines.length)
            subroutines.resize(id+1);
        subroutines[id] = HaSubroutine(isBytecode: true, bytecode: bytecode.nu_dup);
    }

    /**
        Sets a native subroutine within the virtual machine.
    */
    void setSubroutine(int id, HaNativeSubroutine routine) {
        if (id >= subroutines.length)
            subroutines.resize(id+1);
        
        subroutines[id] = HaSubroutine(isBytecode: false, nativeRoutine: routine);
    }

    /**
        Runs the subroutine with the specified ID.
    */
    bool run(int subroutine) {
        if (subroutine >= subroutines.length)
            return false;

        if (subroutines[subroutine].isBytecode)
            return this.run(subroutines[subroutine].bytecode);
        return subroutines[subroutine].nativeRoutine(this, userData);
    }

    /**
        Runs the given program in the virtual machine.

        Params:
            bytecode = The bytecode to execute.

        Returns:
            Whether the bytecode successfully ran.
    */
    bool run(ubyte[] bytecode) {
        
        // VM is already running.
        if (exec)
            return false;

        // Run.
        exec = nogc_new!HaExecutionContext(bytecode);
        while(this.runOne()) {}
        if (auto cexec = exec.pop()) {

            // Cleanup.
            while(cexec.prev)
                cexec = cexec.pop();
            return false;
        }

        // Code exited at the original bytecode.
        return true;
    }
}

/**
    An execution context.
*/
struct HaExecutionContext {
private:
@nogc:
    HaExecutionContext* prev;
    HaExecutionContext* next;

public:
    /**
        The pen in the current execution context.
    */
    vec2 pen = vec2(0, 0);

    // Destructor
    ~this() {

        // Protection from memory leaks.
        if (next)
            nogc_delete(next);
    }

    /**
        Creates a new execution context.
    */
    this(ubyte[] bytecode) {
        this.bytecode = bytecode;
    }

    /**
        Bytecode being executed in the execution context.
    */
    ubyte[] bytecode;

    /**
        Program counter.
    */
    uint pg;

    /**
        Reads a value from the bytecode stream.
    */
    bool read(T)(ref T value) if (T.sizeof <= 4) {
        if (pg+T.sizeof >= bytecode.length)
            return false;

        auto bc = cast(void[])bytecode;
        value = (cast(T[])(bc[pg..pg+T.sizeof]))[0];
        pg += T.sizeof;
        return true;
    }

    /**
        Attempts to jump to the given address.
    */
    bool jump(uint address) {
        if (address >= bytecode.length)
            return false;

        pg = address;
        return true;
    }

    /**
        Pops this execution context from the stack,
        returning the context underneath.
    */
    HaExecutionContext* pop() {
        auto ctx = prev;
        nogc_delete(this);
        
        if (ctx)
            ctx.next = null;
        return ctx;
    }

    /**
        Pushes an execution context to the stack,
        returning the context created.
    */
    HaExecutionContext* push(ubyte[] bytecode) {
        this.next = nogc_new!HaExecutionContext();
        this.next.bytecode = bytecode;
        return this.next;
    }
}

/**
    OpCode list for the unified VM.
*/
alias HaOpCode = ubyte;
enum HaOpCode
    /// NO-OP Instruction
    HA_NOOP = 0x00,

    //
    //      STACK MANAGMENT
    //

    /**
        Instruction:
            Push float32
        
        Stream Arguments:
            [float]

        Stack Push:
            [float result]
    */
    HA_PUSH_F32 = 0x01,

    /**
        Instruction:
            Push int32
        
        Stream Arguments:
            [int]

        Stack Push:
            [int result]
    */
    HA_PUSH_I32 = 0x02,

    /**
        Instruction:
            Peek raw value at stack offset.
        
        Stream Arguments:
            [int stackOffset]

        Stack Arguments:
            [float f ...-stackOffset]

        Stack Push:
            [any result]
    */
    HA_PEEK = 0x03,

    /**
        Instruction:
            Pop Value
    */
    HA_POP = 0x04,

    //
    //      PERSISTENT STORE
    //
    
    /**
        Instruction:
            Set value in persistent store.
        
        Stream Arguments:
            [int value]
            
        Stack Arguments:
            [any value]
    */
    HA_PS_SET = 0x05,
    
    /**
        Instruction:
            Set value in persistent store.
        
        Stream Arguments:
            [int value]
        
        Stack Push:
            [any result]
    */
    HA_PS_GET = 0x06,

    //
    //      MATH
    //

    /**
        Instruction:
            Integer Add

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_ADDI = 0x10,

    /**
        Instruction:
            Float Add

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [float result]
    */
    HA_ADDF = 0x11,

    /**
        Instruction:
            Integer Subtract

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_SUBI = 0x12,

    /**
        Instruction:
            Float Subtract

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [float result]
    */
    HA_SUBF = 0x13,

    /**
        Instruction:
            Integer Multiply

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_MULI = 0x14,

    /**
        Instruction:
            Float Multiply

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [float result]
    */
    HA_MULF = 0x15,

    /**
        Instruction:
            Integer Division

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_DIVI = 0x16,

    /**
        Instruction:
            Float Division

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [float result]
    */
    HA_DIVF = 0x17,

    /**
        Instruction:
            Integer Modulate

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_MODI = 0x18,

    /**
        Instruction:
            Float Modulate

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [float result]
    */
    HA_MODF = 0x19,
    
    /**
        Instruction:
            Integer Compare
        
        Stream Arguments:
            [int stackOffset]

        Stack Arguments:
            [float f ...-stackOffset]

        Stack Push:
            [int result]
    */
    HA_FTOI = 0x1A,
    
    /**
        Instruction:
            Integer Compare

        Stack Arguments:
            [int f ...-stackOffset]

        Stack Push:
            [float result]
    */
    HA_ITOF = 0x1B,
    
    /**
        Instruction:
            Integer Compare

        Stack Arguments:
            [int x, int y]

        Stack Push:
            [int result]
    */
    HA_CMPI = 0x1C,
    
    /**
        Instruction:
            Integer Compare

        Stack Arguments:
            [float x, float y]

        Stack Push:
            [int result]
    */
    HA_CMPF = 0x1D,

    /**
        Instruction:
            Flip Compare Result

        Stack Arguments:
            [int cmp]

        Stack Push:
            [int result]
    */
    HA_NOT = 0x1E,

    /**
        Instruction:
            Linear Interpolate Floats

        Stack Arguments:
            [float a, float b, float t]

        Stack Push:
            [float result]
    */
    HA_MIXF = 0x1F,

    //
    //      CONTROL FLOW
    //

    /**
        Instruction:
            Jump If Equals
        
        Stream Arguments:
            [int address]
        
        Stack Arguments:
            [int result]
    */
    HA_JE = 0xA0,

    /**
        Instruction:
            Jump If Less
        
        Stream Arguments:
            [int address]
        
        Stack Arguments:
            [int result]
    */
    HA_JL = 0xA1,

    /**
        Instruction:
            Jump If Less Than Or Equals
        
        Stream Arguments:
            [int address]
        
        Stack Arguments:
            [int result]
    */
    HA_JLE = 0xA2,

    /**
        Instruction:
            Jump If Greater
        
        Stream Arguments:
            [int address]
        
        Stack Arguments:
            [int result]
    */
    HA_JG = 0xA3,

    /**
        Instruction:
            Jump If Greater Than Or Equals
        
        Stream Arguments:
            [int address]
        
        Stack Arguments:
            [int result]
    */
    HA_JGE = 0xA4,

    /**
        Instruction:
            Jump to Subroutine
        
        Stream Arguments:
            [int subroutine]
    */
    HA_JSR = 0xA5,

    /**
        Instruction:
            Return from Subroutine
    */
    HA_RET = 0xA6,

    //
    //      DRAWING INSTRUCTIONS.
    //
    //      All drawing instructions are relative.
    //

    /**
        Instruction:
            Move To

        Stack Arguments:
            [float x, float y]
    */
    HA_MOVE_TO = 0xF0,

    /**
        Instruction:
            Line To

        Stack Arguments:
            [float x, float y]
    */
    HA_LINE_TO = 0xF1,

    /**
        Instruction:
            Quadratic Curve To

        Stack Arguments:
            [float cx, float cy, float x, float y]
    */
    HA_QUAD_TO = 0xF2,

    /**
        Instruction:
            Cubic Curve To

        Stack Arguments:
            [float c1x, float c1y, float c2x, float c2y, float x, float y]
    */
    HA_CUBIC_TO = 0xF3,
    

    /**
        Instruction:
            Close Path

        Stack Arguments:
            []
    */
    HA_CLOSE_PATH = 0xF4,
    

    /**
        Instruction:
            Move To (Absolute)

        Stack Arguments:
            [float x, float y]
    */
    HA_MOVE_TO_ABS = 0xF5;