/**
    The Unified Hairetsu Bytecode Builder

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.vm.builder;
import nulib.collections.vector;
import nulib.math.fixed;
import nulib.memory.endian;
import hairetsu.font.vm.vm;
import numem;

/**
    A bytecode builder.
*/
final
class HaBytecodeBuilder : NuRefCounted {
private:
@nogc:
    vector!ubyte buffer;

    /*
        Reserves 32 bytes of memory at a time if we fall under a threshold.
    
        This is there to ensure performance.
    */
    void reserveMore() {
        while ((cast(ptrdiff_t)buffer.capacity - cast(ptrdiff_t)buffer.length) < 32) {
            buffer.reserve(buffer.capacity+32);
        }
    }

    auto ref add(T...)(T data) {
        static foreach(element; data) {
            this.reserveMore();

            static if (is(typeof(element) == ubyte)) {
                buffer ~= element;
            } else static if (is(typeof(element) : ubyte[])) {
                buffer ~= element;
            } else static assert(0, "Invalid argument ", typeof(element));
        }

        return this;
    }

public:
    ~this() { buffer.clear(); }

    /**
        Builds a PUSH instruction and adds it to the stream.
    */
    auto buildPush(float value) => this.add(HA_PUSH_F32, value.bytesOf());
    auto buildPush(int value) => this.add(HA_PUSH_I32, value.bytesOf());

    /**
        Builds a PEEK instruction and adds it to the stream.
    */
    auto buildPeek(int offset) => this.add(HA_PEEK, offset.bytesOf());

    /**
        Builds a POP instruction and adds it to the stream.
    */
    auto buildPop() => this.add(HA_POP);

    /**
        Builds a PSTORE Get instruction and adds it to the stream.
    */
    auto buildPSGet(uint slot) => this.add(HA_PS_GET, slot.bytesOf());

    /**
        Builds a PSTORE Set instruction and adds it to the stream.
    */
    auto buildPSSet(uint slot) => this.add(HA_PS_SET, slot.bytesOf());

    /**
        Builds a ADD instruction and adds it to the stream.
    */
    auto buildAdd(T = int)() => this.add(HA_ADDI);
    auto buildAdd(T = float)() => this.add(HA_ADDF);

    /**
        Builds a SUB instruction and adds it to the stream.
    */
    auto buildSub(T = int)() => this.add(HA_SUBI);
    auto buildSub(T = float)() => this.add(HA_SUBF);

    /**
        Builds a MUL instruction and adds it to the stream.
    */
    auto buildMul(T = int)() => this.add(HA_MULI);
    auto buildMul(T = float)() => this.add(HA_MULF);

    /**
        Builds a DIV instruction and adds it to the stream.
    */
    auto buildDiv(T = int)() => this.add(HA_DIVI);
    auto buildDiv(T = float)() => this.add(HA_DIVF);

    /**
        Builds a MOD instruction and adds it to the stream.
    */
    auto buildMod(T = int)() => this.add(HA_MODI);
    auto buildMod(T = float)() => this.add(HA_MODF);

    /**
        Builds a CMP instruction and adds it to the stream.
    */
    auto buildCmp(T = int)() => this.add(HA_CMPI);
    auto buildCmp(T = float)() => this.add(HA_CMPF);
    
    /**
        Builds a NOT instruction and adds it to the stream.
    */
    auto buildNot() => this.add(HA_NOT);

    /**
        Builds a FTOI instruction and adds it to the stream.
    */
    auto buildFtoI(int offset) => this.add(HA_FTOI, offset.bytesOf());

    /**
        Builds a ITOF instruction and adds it to the stream.
    */
    auto buildItoF(int offset) => this.add(HA_ITOF, offset.bytesOf());
    
    /**
        Builds a NOT instruction and adds it to the stream.
    */
    auto buildMix() => this.add(HA_MIXF);

    /**
        Builds a JUMP instruction and adds it to the stream.
    */
    auto buildJE(uint addr) => this.add(HA_JE, addr.bytesOf());
    auto buildJL(uint addr) => this.add(HA_JL, addr.bytesOf());
    auto buildJLE(uint addr) => this.add(HA_JLE, addr.bytesOf());
    auto buildJG(uint addr) => this.add(HA_JG, addr.bytesOf());
    auto buildJGE(uint addr) => this.add(HA_JGE, addr.bytesOf());

    /**
        Builds a JSR instruction and adds it to the stream.
    */
    auto buildJSR(int subroutine) => this.add(HA_JSR, subroutine.bytesOf());

    /**
        Builds a RET instruction and adds it to the stream.
    */
    auto buildRET() => this.add(HA_RET);

    /**
        Builds a MoveToAbs instruction and adds it to the stream.
    */
    auto buildMoveToAbs() => this.add(HA_MOVE_TO_ABS);

    /**
        Builds a MoveTo instruction and adds it to the stream.
    */
    auto buildMoveTo() => this.add(HA_MOVE_TO);

    /**
        Builds a LineTo instruction and adds it to the stream.
    */
    auto buildLineTo() => this.add(HA_LINE_TO);

    /**
        Builds a QuadTo instruction and adds it to the stream.
    */
    auto buildQuadTo() => this.add(HA_QUAD_TO);

    /**
        Builds a CubicTo instruction and adds it to the stream.
    */
    auto buildCubicTo() => this.add(HA_CUBIC_TO);

    /**
        Builds a ClosePath instruction and adds it to the stream.
    */
    auto buildClosePath() => this.add(HA_CLOSE_PATH);


    /**
        Resets the bytecode builder.
    */
    void reset() {
        buffer.clear();
    }

    /**
        Shrinks the internal buffer to fit the data, then
        takes ownership of the bytecode.
    */
    ubyte[] take() {
        ubyte[] rbuf = buffer[].nu_dup;
        
        buffer.clear();
        return rbuf;
    }
}

/**
    Helper which gets the (native endian) bytes of
    the given value.
*/
private
ubyte[T.sizeof] bytesOf(T)(T value) {
    return reinterpret_cast!(ubyte[T.sizeof])(value);
}
