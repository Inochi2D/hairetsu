/**
    OpenType Cmap Table.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: 
        https://learn.microsoft.com/en-us/typography/opentype/spec/cmap
*/
module hairetsu.ot.tables.cmap;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Character to Glyph Index Mapping Table
*/
struct CmapTable {
@nogc:

    /**
        Subtables in the cmap table.
    */
    CmapSubTable[] subtables;

    /**
        Frees the character map.
    */
    void free() {
        foreach(ref subtable; subtables) {
            subtable.free();
        }
        nu_freea(subtables);
    }

    /**
        Deserializes the character map.
    */
    void deserialize(FontReader reader) {
        size_t start = reader.tell();

        ushort tableVersion = reader.readElementBE!ushort();
        ushort tableCount = reader.readElementBE!ushort();

        this.subtables = nu_malloca!CmapSubTable(tableCount);
        switch(tableVersion) {
            case 0:
                foreach(i; 0..tableCount) {
                    ushort platformId = reader.readElementBE!ushort;
                    ushort encodingId = reader.readElementBE!ushort;
                    uint subtableOffset = reader.readElementBE!uint;
                    
                    // Skip non-unicode platforms.
                    if (platformId != 0 && !(platformId == 3 && encodingId == 1))
                        continue;

                    // Read the subtable.
                    size_t next = reader.tell();
                    reader.seek(start+subtableOffset);
                    this.subtables[i] = reader.readRecordBE!CmapSubTable();
                    reader.seek(next);
                }
                return;

            default:
                return;
        }
    }
}

/**
    The subtable
*/
struct CmapSubTable {
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
        ushort segCount;
        ushort searchRange;
        ushort entrySelector;
        ushort rangeShift;
        ushort[] endCode;
        ushort[] startCode;
        short[] idDelta;
        ushort[] idRangeOffset;
        ushort[] glyphIdArray;

        void free() {
            nu_freea(endCode);
            nu_freea(startCode);
            nu_freea(idDelta);
            nu_freea(idRangeOffset);
            nu_freea(glyphIdArray);
        }

        void deserialize(FontReader reader) {
            size_t start = reader.tell()-2;
            length = reader.readElementBE!ushort();
            language = reader.readElementBE!ushort();
            segCount = reader.readElementBE!ushort() / 2;
            
            // Spec recommends skipping these.
            reader.skip(2 * 3);

            // Prepare arrays
            this.endCode = nu_malloca!ushort(segCount);
            this.startCode = nu_malloca!ushort(segCount);
            this.idDelta = nu_malloca!short(segCount);
            this.idRangeOffset = nu_malloca!ushort(segCount);

            reader.readElementsBE(endCode);
            reader.skip(2); // reservedPad
            reader.readElementsBE(startCode);
            reader.readElementsBE(idDelta);
            reader.readElementsBE(idRangeOffset);
            
            // Read all the glyph mappings.
            start = reader.tell() - start;
            this.glyphIdArray = nu_malloca!ushort((length - start)/2);
            reader.readElementsBE(glyphIdArray);
        }
    }

    struct Format6 {
    @nogc:
        ushort length;
        ushort language;
        ushort firstCode;
        ushort[] glyphIdArray;
        
        void free() {
            nu_freea(glyphIdArray);
        }

        void deserialize(FontReader reader) {
            length = reader.readElementBE!ushort();
            language = reader.readElementBE!ushort();
            firstCode = reader.readElementBE!ushort();

            ushort glyphIdArrayLength = reader.readElementBE!ushort();
            this.glyphIdArray = nu_malloca!ushort(glyphIdArrayLength);
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
        SequentialMapGroup[] groups;
        
        void free() {
            nu_freea(groups);
        }

        void deserialize(FontReader reader) {
            reader.skip(2); // reserved
            length = reader.readElementBE!uint();
            language = reader.readElementBE!uint();
            
            uint sequentialMapGroupCount = reader.readElementBE!uint();
            this.groups = nu_malloca!SequentialMapGroup(sequentialMapGroupCount);
            foreach(ref group; groups) {
                group = reader.readRecordBE!SequentialMapGroup();
            }
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

    void free() {
        switch(format) {

            case 4:
                this.format = 0;
                format4.free();
                return;

            case 6:
                this.format = 0;
                format6.free();
                return;

            case 12:
                this.format = 0;
                format12.free();
                return;
            
            default:
                this.format = 0;
                return;
        }
    }

    void deserialize(FontReader reader) {
        format = reader.readElementBE!ushort();

        switch(format) {
            case 0:
                format0 = reader.readRecordBE!Format0();
                break;

            case 4:
                format4 = reader.readRecordBE!Format4();
                break;

            case 6:
                format6 = reader.readRecordBE!Format6();
                break;

            case 12:
                format12 = reader.readRecordBE!Format12();
                break;

            default:
                break;    
        }
    }
}
