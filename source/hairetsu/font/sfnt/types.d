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
        A PostScript font
    */
    postScript
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

/**
    MAXP table
*/
struct SFNTMaxpTable {
    fixed32 version_;
    ushort numGlyphs;
}

struct SFNTOS2Table {
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