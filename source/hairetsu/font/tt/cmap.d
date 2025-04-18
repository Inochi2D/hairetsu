/**
    Hairetsu Character Mapping Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.cmap;
import hairetsu.font.sfnt.reader;
import hairetsu.font.cmap;
import nulib.collections;
import nulib.text.unicode;
import hairetsu.common;
import numem;

/**
    A TrueType character map
*/
class TTCharMap : HaCharMap {
private:
@nogc:
    TTCmapTable cmapTable;
    vector!HaCharRange charRanges;
    set!uint langIds;

public:

    this() { }

    override
    bool hasLanguage(uint langId) {
        return langId in langIds;
    }

    /**
        Gets whether the font has a specified codepoint.

        Params:
            code =  The codepoint to query.
        
        Returns:
            $(D true) if the codepoint was found in the font,
            $(D false) otherwise.
    */
    override
    bool hasCodepoint(codepoint code) {
        foreach(charRange; charRanges) {
            if (code >= charRange.start && code <= charRange.end) {
                return true;
            }
        }
        return false;
    }

    /**
        Gets whether the font has a specified range of codepoints.

        Params:
            range =  The range of codepoints to query.
        
        Returns:
            $(D true) if the range is within the supported ranges
            of the charmap, $(D false) otherwise.
    */
    override
    bool hasCodeRange(HaCharRange range) {
        foreach(charRange; charRanges) {
            if (range.start >= charRange.start && range.end <= charRange.end) {
                return true;
            }
        }
        return false;
    }

    /**
        Gets the glyph index for the specified code point.

        Params:
            code =  The codepoint to query.

        Returns:
            The index of the glyph in the font or
            $(D GLYPH_UNKOWN)
    */
    override
    GlyphIndex getGlyphIndex(codepoint code) {

        // TODO:    Currently this algorithm has no built in
        //          acceleration structures, as such
        //          it may end up being very slow.
        //          This should be optimized by caching ranges and the
        //          best table indices that have a certain char range.
        foreach(TTCmapSubTable table; cmapTable.tables) {
            switch(table.format) {
                case 0:
                    if (code >= 256) 
                        break;
                    
                    return 
                        table.format0.glyphIdArray[code];

                case 4:
                    ushort[] idRangeOffset = table.format4.idRangeOffset;

                    foreach(i; 0..table.format4.segCountX2/2) {
                        uint startCode = table.format4.startCode[i];
                        uint endCode = table.format4.startCode[i];

                        // Skip this range.
                        if (code < startCode || code > endCode)
                            break;

                        if (idRangeOffset[i] == 0) {

                            // NOTE:    Range offset of 0 means that we don't index
                            //          the glyph array!
                            return code + table.format4.idDelta[i];
                        } else {
                            assert(idRangeOffset[i] < table.format4.glyphIdArray.length);
                            return table.format4.glyphIdArray[idRangeOffset[i]];
                        }
                    }
                    break;

                case 6:
                    uint start = table.format6.firstCode;
                    uint length = cast(uint)table.format6.glyphIdArray.length;

                    if (code < start || code > start+length)
                        break;
                    
                    return table.format6.glyphIdArray[code-start];

                case 12:
                    foreach(group; table.format12.groups) {
                        if (code < group.startCharCode || code > group.endCharCode)
                            continue;
                        
                        uint offset = code-group.startCharCode;
                        return offset + group.startGlyphId;
                    }
                    break;

                default:
                    break;
            }
        }
        return GLYPH_UNKOWN;
    }

    /**
        Parses CMAP table.
    */
    void parseCmapTable(SFNTReader reader) {
        this.cmapTable = reader.readRecord!TTCmapTable();

        foreach(TTCmapSubTable table; cmapTable.tables) {
            switch(table.format) {
                case 0:
                    charRanges ~= HaCharRange(0, 255);
                    break;

                case 4:
                    foreach(i; 0..table.format4.segCountX2/2) {
                        uint startCode = table.format4.startCode[i];
                        uint endCode = table.format4.startCode[i];

                        // Skip ending codes.
                        if (startCode == endCode)
                            continue;

                        charRanges ~= HaCharRange(startCode, endCode);
                    }
                    break;

                case 6:
                    uint start = table.format6.firstCode;
                    uint length = cast(uint)table.format6.glyphIdArray.length;

                    charRanges ~= HaCharRange(start, start+length);
                    break;

                case 12:
                    foreach(group; table.format12.groups) {
                        charRanges ~= HaCharRange(group.startCharCode, group.endCharCode);
                    }
                    break;

                default:
                    break;    
            }
        }
    }
}

/**
    CMap Table
*/
struct TTCmapTable {
@nogc:
    ushort tableVersion;
    vector!TTCmapEncodingRecord records;
    vector!TTCmapSubTable tables;

    void deserialize(SFNTReader reader) {
        size_t baseOffset = reader.tell();

        this.tableVersion = reader.readElementBE!ushort();
        
        ushort tableCount = reader.readElementBE!ushort();
        records = reader.readRecords!TTCmapEncodingRecord(tableCount);

        foreach(ref TTCmapEncodingRecord record; records) {
            
            // Skip non-unicode and non-windows platforms
            if (record.platformId != 0 && record.platformId != 3)
                continue;
            
            reader.seek(baseOffset+record.subtableOffset);
            tables ~= reader.readRecord!TTCmapSubTable();
        }
    }
}

/**
    CMap Encoding Record
*/
struct TTCmapEncodingRecord {
@nogc:
    ushort platformId;
    ushort encodingId;
    uint subtableOffset;
}

/**
    The subtable
*/
struct TTCmapSubTable {
@nogc:

    // NOTE:    This one is simple enough to be decoded
    //          automatically.
    struct Format0 {
    @nogc:
        ushort length;
        ushort language;
        ubyte[255] glyphIdArray;
    }

    struct Format4 {
    @nogc:
        ushort length;
        ushort language;
        ushort segCountX2;
        ushort searchRange;
        ushort entrySelector;
        ushort rangeShift;
        vector!ushort endCode;
        vector!ushort startCode;
        vector!short idDelta;
        vector!ushort idRangeOffset;
        vector!ushort glyphIdArray;

        void deserialize(SFNTReader reader) {
            length = reader.readElementBE!ushort();
            language = reader.readElementBE!ushort();
            segCountX2 = reader.readElementBE!ushort();
            searchRange = reader.readElementBE!ushort();
            entrySelector = reader.readElementBE!ushort();
            rangeShift = reader.readElementBE!ushort();

            ushort segCount = segCountX2/2;
            size_t glyphIdArrayLength = 
                length - (
                    14 // length..rangeShift + reservedPad
                    + segCountX2  // endCode..idRangeOffset
            ) / 2;

            // Prepare arrays
            endCode.resize(segCount);
            startCode.resize(segCount);
            idDelta.resize(segCount);
            idRangeOffset.resize(segCount);
            glyphIdArray.resize(glyphIdArrayLength);

            reader.readElementsBE(endCode);
            reader.skip(2); // reservedPad
            reader.readElementsBE(startCode);
            reader.readElementsBE(idDelta);
            reader.readElementsBE(idRangeOffset);
            reader.readElementsBE(glyphIdArray);            
        }
    }

    struct Format6 {
    @nogc:
        ushort length;
        ushort language;
        ushort firstCode;
        vector!ushort glyphIdArray;

        void deserialize(SFNTReader reader) {
            length = reader.readElementBE!ushort();
            language = reader.readElementBE!ushort();
            firstCode = reader.readElementBE!ushort();

            glyphIdArray.resize(reader.readElementBE!ushort());
            reader.readElementsBE(glyphIdArray);
        }
    }

    struct Format12 {
    @nogc:
        struct SequentialMapGroup {
            uint startCharCode;
            uint endCharCode;
            uint startGlyphId;
        }

        uint length;
        uint language;
        vector!SequentialMapGroup groups;

        void deserialize(SFNTReader reader) {
            reader.skip(2); // reserved
            length = reader.readElementBE!uint();
            language = reader.readElementBE!uint();
            groups = reader.readRecords!SequentialMapGroup(reader.readElementBE!uint());
        }
    }

    // Entries
    ushort format;
    union {
        Format0 format0;
        Format4 format4;
        Format6 format6;
        Format12 format12;
    }

    void deserialize(SFNTReader reader) {
        format = reader.readElementBE!ushort();

        switch(format) {
            case 0:
                format0 = reader.readRecord!Format0();
                break;

            case 4:
                format4 = reader.readRecord!Format4();
                break;

            case 6:
                format6 = reader.readRecord!Format6();
                break;

            case 12:
                format12 = reader.readRecord!Format12();
                break;

            default:
                break;    
        }
    }
}
