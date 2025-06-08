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
        ha_freearr(subtables);
    }

    /**
        Deserializes the character map.
    */
    void deserialize(FontReader reader) {
        size_t start = reader.tell();

        ushort tableVersion = reader.readElementBE!ushort();
        ushort tableCount = reader.readElementBE!ushort();

        this.subtables = ha_allocarr!CmapSubTable(tableCount);
        switch(tableVersion) {
            case 0:
                foreach(i; 0..tableCount) {
                    ushort platformId = reader.readElementBE!ushort;
                    ushort encodingId = reader.readElementBE!ushort;
                    uint subtableOffset = reader.readElementBE!uint;
                    
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
        ushort segCountX2;
        ushort searchRange;
        ushort entrySelector;
        ushort rangeShift;
        ushort[] endCode;
        ushort[] startCode;
        short[] idDelta;
        ushort[] idRangeOffset;
        ushort[] glyphIdArray;

        void free() {
            ha_freearr(endCode);
            ha_freearr(startCode);
            ha_freearr(idDelta);
            ha_freearr(idRangeOffset);
            ha_freearr(glyphIdArray);
        }

        void deserialize(FontReader reader) {
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
            this.endCode = ha_allocarr!ushort(segCount);
            this.startCode = ha_allocarr!ushort(segCount);
            this.idDelta = ha_allocarr!short(segCount);
            this.idRangeOffset = ha_allocarr!ushort(segCount);
            this.glyphIdArray = ha_allocarr!ushort(glyphIdArrayLength);

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
        ushort[] glyphIdArray;
        
        void free() {
            ha_freearr(glyphIdArray);
        }

        void deserialize(FontReader reader) {
            length = reader.readElementBE!ushort();
            language = reader.readElementBE!ushort();
            firstCode = reader.readElementBE!ushort();

            ushort glyphIdArrayLength = reader.readElementBE!ushort();
            this.glyphIdArray = ha_allocarr!ushort(glyphIdArrayLength);
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
            ha_freearr(groups);
        }

        void deserialize(FontReader reader) {
            reader.skip(2); // reserved
            length = reader.readElementBE!uint();
            language = reader.readElementBE!uint();
            
            uint sequentialMapGroupCount = reader.readElementBE!uint();
            this.groups = ha_allocarr!SequentialMapGroup(sequentialMapGroupCount);
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
