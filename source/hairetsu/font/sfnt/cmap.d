/**
    Hairetsu Character Mapping Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.cmap;
import hairetsu.font.sfnt;
import hairetsu.font;
import nulib.collections;
import nulib.text.unicode;
import hairetsu.common;
import numem;

import hairetsu.ot.tables.cmap;

/**
    A SFNT character map
*/
class SFNTCharMap : CharMap {
private:
@nogc:
    CmapTable cmapTable;
    vector!CharRange charRanges;

public:

    this() { }

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
    bool hasCodeRange(CharRange range) {
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
        import nulib.text.ascii : isEscapeCharacter;

        // TODO:    Currently this algorithm has no built in
        //          acceleration structures, as such
        //          it may end up being very slow.
        //          This should be optimized by caching ranges and the
        //          best table indices that have a certain char range.
        foreach(CmapSubTable table; cmapTable.subtables) {
            switch(table.format) {
                case 0:
                    if (code >= 255) 
                        break;
                    
                    return 
                        table.format0.glyphIdArray[code];

                case 4:
                    if (code >= 0xFFFF) 
                        break;
                    
                    ushort[] idRangeOffset = table.format4.idRangeOffset;
                    ushort segCount = table.format4.segCount;
                    foreach(i; 0..table.format4.segCount) {
                        uint startCode = table.format4.startCode[i];
                        uint endCode = table.format4.endCode[i];

                        if ((startCode & endCode) == 0xffff)
                            break;

                        // We want the first endCode that's greater or
                        // equal to our code as per spec.
                        if (!(endCode >= code))
                            continue;
                        
                        if (idRangeOffset[i] == 0) {

                            // NOTE:    Range offset of 0 means that we don't index
                            //          the glyph array!
                            return code + table.format4.idDelta[i];
                        } else {

                            // NOTE:    The official spec uses a pointer trick to come
                            //          up with the final value, this converts the
                            //          pointer trick into a slice lookup instead.
                            //          This is safer since the slice is bounds checked.
                            return table.format4.glyphIdArray[
                                i - segCount + idRangeOffset[i]/2 + (code - startCode)
                            ];
                        }
                    }
                    break;

                case 6:
                    uint start = table.format6.firstCode;
                    uint length = cast(uint)table.format6.glyphIdArray.length;

                    if (code < start || code > start+length)
                        break;
                    
                    // Out of range.
                    if (code-start >= table.format6.glyphIdArray.length)
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
        
        return GLYPH_MISSING;
    }

    /**
        Parses CMAP table.
    */
    void parseCmapTable(SFNTReader reader) {
        this.cmapTable = reader.readRecordBE!CmapTable();
        import std.stdio : printf;

        foreach(CmapSubTable table; cmapTable.subtables) {
            switch(table.format) {
                case 0:
                    charRanges ~= CharRange(0, 255);
                    break;

                case 4:
                    foreach(i; 0..table.format4.segCount) {
                        uint startCode = table.format4.startCode[i];
                        uint endCode = table.format4.endCode[i];

                        // Skip ending codes.
                        if ((startCode & endCode) == 0xffff)
                            break;

                        charRanges ~= CharRange(startCode, endCode);
                    }
                    break;

                case 6:
                    uint start = table.format6.firstCode;
                    uint length = cast(uint)table.format6.glyphIdArray.length;

                    charRanges ~= CharRange(start, start+length);
                    break;

                case 12:
                    foreach(group; table.format12.groups) {
                        charRanges ~= CharRange(group.startCharCode, group.endCharCode);
                    }
                    break;

                default:
                    break;    
            }
        }
    }
}
