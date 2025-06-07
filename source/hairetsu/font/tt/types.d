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

struct TTBigGlyphMetrics {
    ubyte height;
    ubyte width;
    byte hBearingX;
    byte hBearingY;
    ubyte hAdvance;
    byte vBearingX;
    byte vBearingY;
    ubyte vAdvance;
}

struct TTSmallGlyphMetrics {
    ubyte height;
    ubyte width;
    byte bearingX;
    byte bearingY;
    ubyte advance;
}


//
//      BITMAPS
//

struct TTEBLCTable {
@nogc:
    size_t eblcStart;
    ushort majorVersion;
    ushort minorVersion;
    vector!TTBitmapSizeRecord sizes;
    
    void deserialize(SFNTReader reader) {
        eblcStart = reader.tell();
        majorVersion = reader.readElementBE!ushort;
        minorVersion = reader.readElementBE!ushort;

        uint num = reader.readElementBE!uint;
        sizes = reader.readRecords!TTBitmapSizeRecord(num);
        foreach(ref size; sizes) {
            size.eblcStart = eblcStart;
            size.parseSubtableHeaders(reader);
        }
    }

    TTBitmapGlyphInfo findGlyph(GlyphIndex glyph, SFNTReader reader, uint baseSize = 0) {
        size_t i = baseSize;
        while(i < sizes.length) {
            if (glyph < sizes[i].startGlyphIndex) {
                i++;
                continue;
            }
            
            if (glyph > sizes[i].endGlyphIndex) {
                i++;
                continue;
            }
            
            return sizes[i].findGlyph(glyph, reader);
        }
        return TTBitmapGlyphInfo.init;
    }
}

struct TTBitmapSizeRecord {
private:
@nogc:
    size_t eblcStart;

public:

    vector!TTIndexSubtableHeaderRecord subtableHeaders;
    uint indexSubtableListOffset;
    uint indexSubtableListSize;
    uint numberOfIndexSubtables;
    TTSbitLineMetricsRecord hori;
    TTSbitLineMetricsRecord verti;
    ushort startGlyphIndex;
    ushort endGlyphIndex;
    ubyte ppemX;
    ubyte ppemY;
    ubyte bitDepth;
    ubyte flags;

    enum ubyte horizontalMetricsFlag = 0x01;
    enum ubyte verticalMetricsFlag = 0x02;

    void deserialize(SFNTReader reader) {
        this.indexSubtableListOffset = reader.readElementBE!uint;
        this.indexSubtableListSize = reader.readElementBE!uint;
        this.numberOfIndexSubtables = reader.readElementBE!uint;
        reader.skip(4); // colorRef
        this.hori = reader.readRecord!TTSbitLineMetricsRecord();
        this.verti = reader.readRecord!TTSbitLineMetricsRecord();
        this.startGlyphIndex = reader.readElementBE!ushort;
        this.endGlyphIndex = reader.readElementBE!ushort;
        this.ppemX = reader.readElementBE!ubyte;
        this.ppemY = reader.readElementBE!ubyte;
        this.bitDepth = reader.readElementBE!ubyte;
        this.flags = reader.readElementBE!ubyte;
    }

    void parseSubtableHeaders(SFNTReader reader) {
        reader.seek(eblcStart+indexSubtableListOffset);
        subtableHeaders = reader.readRecords!TTIndexSubtableHeaderRecord(numberOfIndexSubtables);
    }
    
    TTBitmapGlyphInfo findGlyph(GlyphIndex glyph, SFNTReader reader) {
        TTBitmapGlyphInfo glyphInfo;
        foreach(ref TTIndexSubtableHeaderRecord subtable; subtableHeaders) {
            if (glyph < subtable.firstGlyphIndex)
                continue;

            if (glyph > subtable.lastGlyphIndex)
                continue;
            
            // Seek to the relevant subtable.
            reader.seek(eblcStart+indexSubtableListOffset+subtable.indexSubtableOffset);
            ushort indexFormat = reader.readElementBE!ushort;
            glyphInfo.imageFormat = reader.readElementBE!ushort;
            glyphInfo.imageDataOffset = reader.readElementBE!uint;
            switch(indexFormat) {
                case 1:
                    reader.skip((glyph-subtable.firstGlyphIndex)*4);
                    glyphInfo.sbitOffset = reader.readElementBE!uint;
                    glyphInfo.imageSize = (reader.readElementBE!uint)-glyphInfo.sbitOffset;
                    return glyphInfo;
                case 2:
                    glyphInfo.imageSize = reader.readElementBE!uint;
                    glyphInfo.metrics = reader.readRecord!TTBigGlyphMetrics;
                    glyphInfo.sbitOffset = 0;
                    return glyphInfo;
                case 3:
                    reader.skip((glyph-subtable.firstGlyphIndex)*2);
                    glyphInfo.sbitOffset = reader.readElementBE!ushort;
                    glyphInfo.imageSize = (cast(uint)reader.readElementBE!ushort)-glyphInfo.sbitOffset;
                    return glyphInfo;
                case 4:
                    uint numGlyphs = reader.readElementBE!uint;
                    foreach(i; 0..numGlyphs) {
                        ushort glyphId = reader.readElementBE!ushort;
                        ushort sbitOffset = reader.readElementBE!ushort;

                        if (glyphId == glyph) {
                            reader.skip(2);
                            uint sbitOffsetNext = reader.readElementBE!ushort;
                            glyphInfo.sbitOffset = sbitOffset;
                            glyphInfo.imageSize = sbitOffsetNext-sbitOffset;
                            return glyphInfo;
                        }
                    }
                    break;
                case 5:
                    glyphInfo.imageSize = reader.readElementBE!uint;
                    glyphInfo.metrics = reader.readRecord!TTBigGlyphMetrics;
                    uint numGlyphs = reader.readElementBE!uint;
                    foreach(i; 0..numGlyphs) {

                        ushort glyphId = reader.readElementBE!ushort;
                        if (glyphId == glyph)
                            return glyphInfo;
                    }
                    break;
                default: break;
            }
        }

        return TTBitmapGlyphInfo.init;
    }
}

struct TTSbitLineMetricsRecord {
@nogc:
    byte ascender;
    byte descender;
    ubyte widthmax;
    byte caretSlopeNumerator;
    byte caretSlopeDenominator;
    byte caretOffset;
    byte minOriginSB;
    byte minAdvanceSB;
    byte maxBeforeBL;
    byte minAfterBL;
    byte pad1;
    byte pad2;
}

struct TTIndexSubtableHeaderRecord {
@nogc:
    ushort firstGlyphIndex;
    ushort lastGlyphIndex;
    uint indexSubtableOffset;
}

struct TTBitmapGlyphInfo {
@nogc:
    uint imageDataOffset;
    uint sbitOffset;
    uint imageSize;
    TTBigGlyphMetrics metrics;
    ushort imageFormat;
}