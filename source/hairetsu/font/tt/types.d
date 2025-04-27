/**
    Hairetsu TrueType Tags, Tables and Records.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.types;
import hairetsu.font.sfnt.reader;
import nulib.collections;
import hairetsu.common;
import numem;

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

struct TTGlyfTableHeader {
    short numberOfCountours;
    short xMin;
    short yMin;
    short xMax;
    short yMax;
}

struct TTGlyfTable {
@nogc:

    ~this() {
        if (header.numberOfCountours > 0)
            nogc_delete(simple); 
    }

    TTGlyfTableHeader header;
    union {
        TTSimpleGlyphRecord simple;
    }

    void deserialize(SFNTReader reader) {
        header = reader.readRecord!TTGlyfTableHeader;

        if (header.numberOfCountours >= 0) {

            // Read contours
            simple.endPtsOfContours.resize(header.numberOfCountours);
            reader.readElementsBE!ushort(simple.endPtsOfContours[]);

            // Read instructions
            ushort instructionCount = reader.readElementBE!ushort;
            if (instructionCount > 0) {
                simple.instructions.resize(instructionCount);
                reader.read(simple.instructions);
            }

            ushort pointCount = cast(ushort)(simple.endPtsOfContours[$-1]+1);
            if (pointCount > 0) {
                simple.flags.resize(pointCount);
                simple.contours.resize(pointCount);

                // Read and expand flags
                for (size_t i = 0; i < pointCount; i++) {
                    ubyte flag = reader.readElementBE!ubyte;
                    simple.flags[i] = flag;

                    if (flag & REPEAT_FLAG) {
                        ubyte repeat = reader.readElementBE!ubyte;
                        foreach(_; 0..repeat) {
                            if (i+1 >= pointCount) break;

                            simple.flags[++i] = flag;
                        }
                    }
                }


                // Read X coordinates
                for (size_t i = 0; i < pointCount; i++) {
                    int coordinate;
                    ubyte flag = simple.flags[i];
                    bool sameOrSign = (flag & X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR) > 0;

                    if (flag & X_SHORT_VECTOR) {
                        coordinate = sameOrSign ? 
                            reader.readElementBE!ubyte :
                            -(cast(int)reader.readElementBE!ubyte);
                    } else {
                        coordinate = sameOrSign ? 
                            0 : // No change
                            reader.readElementBE!short;
                    }

                    simple.contours[i].x = coordinate;
                }

                // Read Y coordinates
                for (size_t i = 0; i < pointCount; i++) {
                    int coordinate;
                    ubyte flag = simple.flags[i];
                    bool sameOrSign = (flag & Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR) > 0;

                    if (flag & Y_SHORT_VECTOR) {
                        coordinate = sameOrSign ? 
                            reader.readElementBE!ubyte :
                            -(cast(int)reader.readElementBE!ubyte);
                    } else {
                        coordinate = sameOrSign ? 
                            0 : // No change
                            reader.readElementBE!short;
                    }

                    simple.contours[i].y = coordinate;
                }
            }
        }
    }
}

enum ubyte 
    ON_CURVE_POINT                          = 0x01,
    X_SHORT_VECTOR                          = 0x02,
    Y_SHORT_VECTOR                          = 0x04,
    REPEAT_FLAG                             = 0x08,
    X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR    = 0x10,
    Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR    = 0x20,
    OVERLAP_SIMPLE                          = 0x40;

struct TTSimpleGlyphRecord {
    vector!ushort endPtsOfContours;
    vector!ubyte instructions;
    vector!ubyte flags;
    vector!(HaVec2!float) contours;
}