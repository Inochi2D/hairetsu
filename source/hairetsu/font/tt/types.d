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

//
//      SVG
//

struct TTSVGTable {
private:
@nogc:
    size_t svgTableOffset;
    size_t svgDocListOffset;

public:
    ushort version_;
    vector!SVGDocumentRecord svgDocuments;
    
    void deserialize(SFNTReader reader) {
        this.svgTableOffset = reader.tell();
        this.version_ = reader.readElementBE!ushort;
        this.svgDocListOffset = reader.readElementBE!uint;

        reader.seek(svgTableOffset+svgDocListOffset);

        ushort entries = reader.readElementBE!ushort;
        this.svgDocuments = reader.readRecords!SVGDocumentRecord(entries);
    }

    SVGDocumentRecord findGlyph(GlyphIndex glyph) {
        foreach(document; svgDocuments) {
            if (glyph < document.startGlyph)
                continue;

            if (glyph > document.endGlyph)
                continue;
        
            return document;
        }
        return SVGDocumentRecord.init;
    }

    ubyte[] readGlyphData(SFNTReader reader, GlyphIndex glyph) {
        SVGDocumentRecord doc = this.findGlyph(glyph);
        if (doc.startGlyph == doc.endGlyph)
            return null;

        ubyte[] buffer;
        buffer = buffer.nu_resize(doc.svgDocLength);
        reader.seek(svgTableOffset+svgDocListOffset+doc.svgDocOffset);
        reader.read(buffer);
        return buffer;
    }
}

struct SVGDocumentRecord {
    ushort startGlyph;
    ushort endGlyph;
    uint svgDocOffset;
    uint svgDocLength;
}

//
//      GLYF
//

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
        }
    }
}

struct TTSimpleGlyphRecord {
    vector!ushort endPtsOfContours;
    vector!ubyte instructions;
    vector!ubyte flags;
    vector!vec2 contours;
}