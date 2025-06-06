/**
    OpenType Hmtx Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/hmtx
*/
module hairetsu.font.tables.hmtx;
import hairetsu.font.tables.hhea;
import hairetsu.font.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Horizontal Metrics Table
*/
struct HmtxTable {
@nogc:

    /**
        Metric records
    */
    MtxRecord[] records;

    /**
        Frees the table.
    */
    void free() {
        ha_freearr(records);
    }

    /**
        Deserializes the table.
    */
    void deserialize(SFNTReader reader, HheaTable hhea, uint glyphCount) {
        this.records = ha_allocarr!MtxRecord(glyphCount);
        foreach(i; 0..glyphCount) {
            if (i < hhea.numberOfHMetrics)            
                this.records[i] = reader.readRecord!MtxRecord();
            else
                this.records[i].bearing = reader.readElementBE!short;
        }
    }
}
