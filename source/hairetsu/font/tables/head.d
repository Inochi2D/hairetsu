/**
    OpenType Head Table.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/head
*/
module hairetsu.font.tables.head;
import hairetsu.font.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Font Header Table
*/
struct HeadTable {
    ushort majorVersion;
    ushort minorVersion;
    fixed32 fontRevision;
    uint checksumAdjustment;
    uint magicNumber;
    ushort flags;
    ushort unitsPerEm;
    long created;
    long modified;
    short xMin;
    short yMin;
    short xMax;
    short yMax;
    ushort macStyle;
    ushort lowestRecPPEM;
    short fontDirectionHint;
    short indexToLocFormat;
    short glyphDataFormat;
}