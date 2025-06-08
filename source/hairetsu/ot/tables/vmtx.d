/**
    OpenType Vmtx Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/vmtx
*/
module hairetsu.ot.tables.vmtx;
import hairetsu.ot.tables.vhea;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Vertical Metrics Table
*/
struct VmtxTable {
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
    void deserialize(SFNTReader reader, VheaTable vhea, uint glyphCount) {
        this.records = ha_allocarr!MtxRecord(glyphCount);
        foreach(i; 0..glyphCount) {
            if (i < vhea.numberOfVMetrics)            
                this.records[i] = reader.readRecord!MtxRecord();
            else
                this.records[i].bearing = reader.readElementBE!short;
        }
    }
}
