/**
    Hairetsu SFNT Base Tables and Records.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.types;
import hairetsu.common;

/**
    The type of the SFNT
*/
enum SNFTFontType {

    /**
        A CFF1/2 OpenType Font
    */
    openType,
    
    /**
        A TrueType font
    */
    trueType,
    
    /**
        A Type1 font
    */
    type1
}

/**
    The header of a SFNT
*/
struct SFNTHeader {
    uint sfntVersion;
    ushort tableCount;
    ushort searchRange;
    ushort entrySelector;
    ushort rangeShift;
}

/**
    A table record of a SFNT
*/
struct SFNTTableRecord {
    uint tag;
    uint checksum;
    uint offset;
    uint length;
}

/**
    A name record
*/
struct SFNTNameRecord {
    ushort platformId;
    ushort encodingId;
    ushort languageId;
    ushort nameId;
    ushort length;
    ushort offset;
}