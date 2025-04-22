/**
    Hairetsu TrueType VM

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.vm;
import hairetsu.font.tt.types;
import nulib.collections.vector;
import nulib.io.stream.memstream;
import nulib.io.stream.rw;
import nulib.math.fixed;
import numem;

import hairetsu.common;
import hairetsu.glyph.outline;

/**
    TrueType Outline Virtual Machine
*/
class TTVirtualMachine : NuRefCounted {
private:
@nogc:
    TTGraphicsState state;
    MemoryStream program;
    StreamReader reader;

    vector!uint stack;
    vector!uint storage;
    vector!fixed26_6 cvt;
    HaVec2!float[][2] zones;

    //
    //          VM IMPLEMENTATION
    //
    bool interpret(bool glyphExec) {

        // EOF
        if (program.tell+1 == program.length)
            return false;

        ubyte opcode = reader.readBE!ubyte();
        switch(opcode) {

            // NPUSHB[ ]
            case 0x40:
                ubyte n = reader.readBE!ubyte();
                foreach(i; 0..n)
                    this.stackPush(reader.readBE!ubyte());
                
                return true;

            // NPUSHW[ ]
            case 0x41:
                ubyte n = reader.readBE!ubyte();
                foreach(i; 0..n)
                    this.stackPush(reader.readBE!short());
                
                return true;

            // PUSHB[abc]
            case 0xB0:
            case 0xB1:
            case 0xB2:
            case 0xB3:
            case 0xB4:
            case 0xB5:
            case 0xB6:
            case 0xB7:

                // Encoded as max 8 bytes to push
                ubyte n = 1+(opcode & 0b00000111);
                foreach(i; 0..n)
                    this.stackPush(reader.readBE!ubyte());
                
                return true;

            // PUSHW[abc]
            case 0xB8:
            case 0xB9:
            case 0xBA:
            case 0xBB:
            case 0xBC:
            case 0xBD:
            case 0xBE:
            case 0xBF:

                // Encoded as max 8 bytes to push
                ubyte n = 1+(opcode & 0b00000111);
                foreach(i; 0..n)
                    this.stackPush(reader.readBE!short());
                
                return true;
            
            // RS[ ]
            case 0x43:
                uint location;
                uint value;

                if (!this.stackPop(location))
                    return false;
                    
                if (!this.storageGet(location, value))
                    return false;

                this.stackPush(value);
                return true;

            // WS[ ]
            case 0x42:
                uint value;
                uint location;

                if (!this.stackPop(value))
                    return false;

                if (!this.stackPop(location))
                    return false;
                
                return this.storageSet(location, value);
            
            // WCVTP[ ]
            case 0x44:
                uint value;
                uint location;

                if (!this.stackPop(value))
                    return false;

                if (!this.stackPop(location))
                    return false;

                this.cvtSet(location, fixed26_6.fromData(value));
                return true;
            
            // WCVTF[ ]
            case 0x70:
                uint value;
                uint location;

                if (!this.stackPop(value))
                    return false;

                if (!this.stackPop(location))
                    return false;

                this.cvtSet(location, fixed26_6.fromData(value)*state.ppem);
                return true;

            // RCVT[ ]
            case 0x45:
                uint location;
                fixed26_6 value;

                if (!this.stackPop(location))
                    return false;

                if (!this.cvtGet(location, value))
                    return false;

                this.stackPush(value.data);
                return true;

            // SVTCA[a]
            case 0x00:
            case 0x01:
                int x = opcode == 0 ? 0 : 1;
                int y = !x;
                
                state.projectionVector.x = x;
                state.projectionVector.y = y;
                state.freedomVector.x = x;
                state.freedomVector.y = y;
                return true;

            // SPVTCA[a]
            case 0x02:
            case 0x03:
                int x = opcode == 2 ? 0 : 1;
                int y = !x;
                
                state.projectionVector.x = x;
                state.projectionVector.y = y;
                return true;

            // SFVTCA[a]
            case 0x04:
            case 0x05:
                int x = opcode == 4 ? 0 : 1;
                int y = !x;
                
                state.freedomVector.x = x;
                state.freedomVector.y = y;
                return true;

            // SPVTL[a]
            case 0x06:
            case 0x07:
                bool a = opcode == 0x06;
                uint p1;
                uint p2;

                if (!this.stackPop(p1))
                    return false;

                if (!this.stackPop(p2))
                    return false;

                auto point1 = fetchZone(state.zp2)[p1];
                auto point2 = fetchZone(state.zp1)[p2];
                HaVec2!fixed2_14 result = HaVec2!fixed2_14(
                    x: fixed2_14(point1.x-point2.x),
                    y: fixed2_14(point1.y-point2.y)
                ).normalized();

                state.projectionVector = a ? 
                    result : 
                    result.perpendicular();
                
                state.dualProjectionVector = state.projectionVector;
                return true;

            // SFVTL[a]
            case 0x08:
            case 0x09:
                bool a = opcode == 0x08;
                uint p1;
                uint p2;

                if (!this.stackPop(p1))
                    return false;

                if (!this.stackPop(p2))
                    return false;

                auto point1 = fetchZone(state.zp2)[p1];
                auto point2 = fetchZone(state.zp1)[p2];
                HaVec2!fixed2_14 result = HaVec2!fixed2_14(
                    x: fixed2_14(point1.x-point2.x),
                    y: fixed2_14(point1.y-point2.y)
                ).normalized();

                state.freedomVector = a ? 
                    result : 
                    result.perpendicular();
                
                return true;

            // SFVTPV[a]
            case 0x0E:
                state.freedomVector = state.projectionVector;
                return true;

            // SDPVTL[a]
            case 0x86:
            case 0x87:
                bool a = opcode == 0x86;
                uint p1;
                uint p2;

                if (!this.stackPop(p1))
                    return false;

                if (!this.stackPop(p2))
                    return false;

                auto point1 = fetchZone(state.zp2)[p1];
                auto point2 = fetchZone(state.zp1)[p2];
                HaVec2!fixed2_14 result = HaVec2!fixed2_14(
                    x: fixed2_14(point1.x-point2.x),
                    y: fixed2_14(point1.y-point2.y)
                ).normalized();

                state.dualProjectionVector = a ? 
                    result : 
                    result.perpendicular();
                return true;
            
            // SPVFS[ ]
            case 0x0A:
                short y;
                short x;

                if (!this.stackPop(y))
                    return false;

                if (!this.stackPop(x))
                    return false;

                state.projectionVector.x = fixed2_14.fromData(x);
                state.projectionVector.y = fixed2_14.fromData(y);
                state.dualProjectionVector = state.projectionVector;
                return true;
            
            // SFVFS[ ]	
            case 0x0B:
                short y;
                short x;

                if (!this.stackPop(y))
                    return false;

                if (!this.stackPop(x))
                    return false;

                state.freedomVector.x = fixed2_14.fromData(x);
                state.freedomVector.y = fixed2_14.fromData(y);
                return true;
            
            // GPV[ ]
            case 0x0C:
                this.stackPush!short(state.projectionVector.x.data);
                this.stackPush!short(state.projectionVector.y.data);
                return true;
            
            // GFV[ ]
            case 0x0D:
                this.stackPush!short(state.freedomVector.x.data);
                this.stackPush!short(state.freedomVector.y.data);
                return true;
            
            // SRP0[ ]
            case 0x10:
                uint p;
                if (!this.stackPop(p))
                    return false;

                state.rp0 = p;
                return true;
            
            // SRP1[ ]
            case 0x11:
                uint p;
                if (!this.stackPop(p))
                    return false;

                state.rp1 = p;
                return true;
            
            // SRP2[ ]
            case 0x12:
                uint p;
                if (!this.stackPop(p))
                    return false;

                state.rp2 = p;
                return true;
            
            // SZP0[ ]
            case 0x13:
                uint n;
                if (!this.stackPop(n))
                    return false;

                if (n > 1)
                    return false;

                state.zp0 = n;
                return true;
            
            // SZP1[ ]
            case 0x14:
                uint n;
                if (!this.stackPop(n))
                    return false;

                if (n > 1)
                    return false;

                state.zp1 = n;
                return true;
            
            // SZP2[ ]
            case 0x15:
                uint n;
                if (!this.stackPop(n))
                    return false;

                if (n > 1)
                    return false;

                state.zp2 = n;
                return true;
            
            // SZPS[ ]
            case 0x16:
                uint n;
                if (!this.stackPop(n))
                    return false;

                if (n > 1)
                    return false;

                state.zp0 = n;
                state.zp1 = n;
                state.zp2 = n;
                return true;
            
            // RTG[ ]
            case 0x18:
                state.roundState = 1;
                return true;
            
            // RTHG[ ]
            case 0x19:
                state.roundState = 0;
                return true;
            
            // RTDG[ ]
            case 0x3D:
                state.roundState = 2;
                return true;
            
            // RUTG[ ]
            case 0x7C:
                state.roundState = 4;
                return true;
            
            // RDTG[ ]
            case 0x7D:
                state.roundState = 3;
                return true;
            
            // ROFF[ ]
            case 0x7A:
                state.roundState = 5;
                return true;

            // SROUND[ ]
            case 0x76:
                uint n;

                if (!this.stackPop(n))
                    return false;

                this.setCustomRoundState(n, fixed26_6(1));
                return true;

            // S45ROUND[ ]
            case 0x77:
                uint n;

                if (!this.stackPop(n))
                    return false;

                import nulib.c.math : sqrt;
                this.setCustomRoundState(n, fixed26_6(sqrt(2)/2.0));
                return true;
            
            // SLOOP[ ]
            case 0x17:
                uint n;

                if (!this.stackPop(n))
                    return false;
                
                state.loop = n;
                return true;

            // SMD[ ]
            case 0x1A:
                uint distance;

                if (!this.stackPop(distance))
                    return false;
                
                state.minimumDistance = fixed26_6.fromData(distance);
                return true;
            
            // INSTCTRL[ ]
            case 0x8E:
                // TODO: Implement this?
                return true;
            
            // SCANCTRL[ ]
            case 0x85:
                // TODO: Implement this?
                return true;
            
            // SCANTYPE[ ]
            case 0x8D:
                // TODO: Implement this?
                return true;
            
            // SCVTCI[ ]
            case 0x1D:
                return true;
            
            // AAAAAAAAA
            case 0xFF:
                return true;
                
            default:
                return false;
        }
    }


    //
    //          DATA MANAGMENT.
    //
    void stackPush(T)(T value) if (__traits(isIntegral, T)) {
        static if (__traits(isUnsigned, T))
            stack ~= cast(uint)value;
        else    
            stack ~= reinterpret_cast!uint(cast(int)value);
    }

    bool stackPop(T)(ref T result) {
        if (stack.length == 0)
            return false;
        
        static if (__traits(isUnsigned, T))
            result = cast(T)stack[$-1];
        else 
            result = cast(T)reinterpret_cast!int(stack[$-1]);
        
        stack.popBack();
        return true;
    }

    bool storageGet(uint location, ref uint result) {
        if (location >= storage.length)
            return false;
        
        result = storage[location];
        return true;
    }

    bool storageSet(uint location, uint value) {
        if (location >= storage.length)
            return false;
            
        storage[location] = value;
        return true;
    }

    bool cvtGet(uint location, ref fixed26_6 result) {
        if (location >= cvt.length)
            return false;
        
        result = storage[location];
        return true;
    }

    void cvtSet(uint location, fixed26_6 value) {
        if (location >= cvt.length)
            cvt.resize(location+1);
            
        cvt[location] = value;
    }
    

    //
    //      ROUNDING
    //
    void setCustomRoundState(uint n, fixed26_6 gridPeriod) {
        state.roundState = 6;

        // Get indices for the lookup tables.
        ubyte periodIdx    = cast(ubyte)((n >>> 6) & 0b00000011);
        ubyte phaseIdx     = cast(ubyte)((n >>> 4) & 0b00000011);
        ubyte thresholdIdx = cast(ubyte)(n & 0b00001111);

        state.period = gridPeriod * periodFactors[periodIdx];
        state.phase = state.period * phaseFactors[phaseIdx];
        state.threshold = (state.period * thresholdFactors[thresholdIdx]) - thresholdSubtractTable[thresholdIdx];
    }

    //
    //      GRAPHICS STATE
    //

    HaVec2!float[] fetchZone(uint zoneId) {
        if (zoneId > 1) return null;
        return zones[zoneId]; 
    }


    // Graphics State
    struct TTGraphicsState {
        bool autoFlip = true;
        fixed26_6 controlValueCutIn = 16;
        uint deltaBase = 9;
        uint deltaShift = 3;
        HaVec2!fixed2_14 dualProjectionVector;
        HaVec2!fixed2_14 freedomVector = { fixed2_14(1), fixed2_14(0) };
        uint zp0 = 1;
        uint zp1 = 1;
        uint zp2 = 1;
        uint instructionControl = 0;
        uint loop = 0;
        fixed26_6 minimumDistance = fixed26_6(1);
        HaVec2!fixed2_14 projectionVector = { fixed2_14(1), fixed2_14(0) };
        uint roundState = 1;
        fixed26_6 period = fixed2_14(1);
        fixed26_6 phase = fixed2_14(0);
        fixed26_6 threshold = fixed2_14(0.5);
        uint rp0 = 1;
        uint rp1 = 1;
        uint rp2 = 1;
        bool scanControl = false;
        fixed26_6 singeWidthCutIn = fixed26_6(0);
        fixed26_6 singleWidthValue = fixed26_6(0);
        uint ppem;
    }
    
public:
    
    /**
        Runs the given program
    */
    final
    void run(ubyte[] instructions) {
        nogc_initialize(state);
        stack.resize(0);

        // Close old program and write new program in,
        // then run it.
        program.close();
        program.write(instructions[]);
        program.seek(0);

        // Max points = outline point count * 2
        // ... for now.
        zones[0] = zones[0].nu_resize(0);
        zones[1] = zones[1].nu_resize(0);

        // Interpret program.
        while(interpret(false)) {}
    }
    
    /**
        Runs the given program
    */
    final
    void run(ref TTGlyfTable glyf, uint ppem) {
        if (glyf.header.numberOfCountours == 0)
            return;
        

        nogc_initialize(state);
        state.ppem = ppem;
        stack.resize(0);

        if (glyf.header.numberOfCountours > 0) {

            // Close old program and write new program in,
            // then run it.
            program.close();
            program.write(glyf.simple.instructions[]);
            program.seek(0);

            // Max points = outline point count * 2
            // ... for now.
            zones[0] = zones[0].nu_resize(glyf.simple.contours.length*2);
            zones[1] = glyf.simple.contours[];

            // Interpret program.
            while(interpret(true)) {}
        }
    }
}


private:


__gshared float[4] periodFactors = [0.5, 1, 2];
__gshared float[4] phaseFactors = [0, 0.25, 0.5, 3.0/4.0];
__gshared float[16] thresholdFactors = [
     1,
    -3.0/8.0,
    -2.0/8.0,
    -1.0/8.0,
     0.0/8.0,
     1.0/8.0,
     2.0/8.0,
     3.0/8.0,
     4.0/8.0,
     5.0/8.0,
     6.0/8.0,
     7.0/8.0,
     1,
    9.0/8.0,
    10.0/8.0,
    11.0/8.0,
];

__gshared float[16] thresholdSubtractTable = [
    1, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0
];