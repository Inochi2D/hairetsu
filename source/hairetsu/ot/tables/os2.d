/**
    OpenType OS/2 Table.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/head
*/
module hairetsu.ot.tables.os2;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    OS/2 Table
*/
struct OS2Table {
    ushort version_;
    short xAvgCharWidth;
    ushort usWeightClass;
    ushort usWidthClass;
    ushort fsType;
    short ySubscriptXSize;
    short ySubscriptYSize;
    short ySubscriptXOffset;
    short ySubscriptYOffset;
    short ySuperscriptXSize;
    short ySuperscriptYSize;
    short ySuperscriptXOffset;
    short ySuperscriptYOffset;
    short yStrikeoutSize;
    short yStrikeoutPosition;
    short sFamilyClass;
    ubyte[10] panose;
    uint ulUnicodeRange1;
    uint ulUnicodeRange2;
    uint ulUnicodeRange3;
    uint ulUnicodeRange4;
    Tag achVendID;
    ushort fsSelection;
    ushort usFirstCharIndex;
    ushort usLastCharIndex;
    short sTypoAscender;
    short sTypoDescender;
    short sTypoLineGap;
    ushort usWinAscent;
    ushort usWinDescent;
    uint ulCodePageRange1;
    uint ulCodePageRange2;
    ushort sxHeight;
    ushort sCapHeight;
    ushort usDefaultChar;
    ushort usBreakChar;
    ushort usMaxContext;
    ushort usLowerOpticalPointSize;
    ushort usUpperOpticalPointSize;
}
