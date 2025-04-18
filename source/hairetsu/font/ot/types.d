/**
    Hairetsu OpenType Tags, Tables and Records.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.ot.types;
import hairetsu.common;


/// OpenType FVar Table Header
struct OTFVarHeader {
    ushort majorVersion;
    ushort minorVersion;
    ushort axesArrayOffset;
    ushort reserved = 2;
    ushort axisCount;
    ushort axisSize;
    ushort instanceCount;
    ushort instanceSize;
}

enum ushort HIDDEN_AXIS = 0x0001;
enum ushort RESERVED_AXIS = 0xFFFE;
struct OTVariationAxisRecord {
    uint axisTag;
    fixed32 minValue;
    fixed32 defaultValue;
    fixed32 maxValue;
    ushort flags;
    ushort axisNameID;
}

struct OTInstanceRecord {
    
}