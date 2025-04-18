/**
    Hairetsu TrueType Tags, Tables and Records.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.types;
import hairetsu.common;

struct TTHeadTable {
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

struct TTHheaTable {
    ushort majorVersion;
    ushort minorVersion;
    short ascender;
    short descender;
    short lineGap;
    ushort advanceWidthMax;
    short minLeftSideBearing;
    short minRightSideBearing;
    short xMaxExtent;
    short caretSlopeRise;
    short caretSlopeRun;
    short caretOffset;
    short reserved0;
    short reserved1;
    short reserved2;
    short reserved3;
    short metricDataFormat;
    short numberOfHMetrics;
}

struct TTVheaTable {
    fixed32 version_;
    short ascender;
    short descender;
    short lineGap;
    ushort advanceHeightMax;
    short minTopSideBearing;
    short minBottomSideBearing;
    short yMaxExtent;
    short caretSlopeRise;
    short caretSlopeRun;
    short caretOffset;
    short reserved0;
    short reserved1;
    short reserved2;
    short reserved3;
    short metricDataFormat;
    short numberOfVMetrics;
}

struct TTMetricRecord {
    ushort advance;
    short bearing;
}