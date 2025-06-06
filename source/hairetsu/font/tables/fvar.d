/**
    OpenType FVar Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/fvar
*/
module hairetsu.font.tables.fvar;
import hairetsu.font.tables.common;
import hairetsu.font.sfnt.reader;

/**
    The FVar Table
*/
struct FVarTable {
@nogc:

    /**
        Major version number of the font variations table — set to 1.
    */
    ushort majorVersion;
    
    /**
        Minor version number of the font variations table — set to 0.
    */
    ushort minorVersion;
    
    /**
        The variation axis array.
    */
    FVarVariationAxisRecord[] axes;
    
    /**
        The named instance array.
    */
    FVarInstanceRecord[] instances;
    
    void free() {
        foreach(ref instance; instances) {
            instance.free();
        }
        ha_freearr(axes);
        ha_freearr(instances);
    }

    void deserialize(SFNTReader reader) {
        size_t start = reader.tell();

        // Read base info
        this.majorVersion = reader.readElementBE!ushort;
        this.minorVersion = reader.readElementBE!ushort;

        // The records.
        ushort axesArrayOffset = reader.readElementBE!ushort;
        reader.skip(2);

        ushort axisCount = reader.readElementBE!ushort;
        ushort axisSize = reader.readElementBE!ushort;
        ushort instanceCount = reader.readElementBE!ushort;
        ushort instanceSize = reader.readElementBE!ushort;

        this.axes = ha_allocarr!FVarVariationAxisRecord(axisCount);
        this.instances = ha_allocarr!FVarInstanceRecord(instanceCount);

        // Variation Axis
        reader.seek(start+axesArrayOffset);
        foreach(ref FVarVariationAxisRecord axis; this.axes) {
            size_t ioffset = reader.tell();
            axis = reader.readRecord!FVarVariationAxisRecord;
            reader.seek(ioffset+axisSize);
        }

        // Instance
        foreach(ref FVarInstanceRecord instance; this.instances) {
            size_t ioffset = reader.tell();
            instance.deserialize(reader, axisCount);
            reader.seek(ioffset+instanceSize);
        }
    }
}

struct FVarVariationAxisRecord {
@nogc:
    
    /**
        Tag identifying the design variation for the axis.
    */
    Tag axisTag;
    
    /**
        The minimum coordinate value for the axis.
    */
    fixed32 minValue;
    
    /**
        The default coordinate value for the axis.
    */
    fixed32 defaultValue;
    
    /**
        The maximum coordinate value for the axis.
    */
    fixed32 maxValue;
    
    /**
        Axis qualifiers.
    */
    ushort flags;
    
    /**
        The name ID for entries in the 'name' table that provide a 
        display name for this axis.
    */
    ushort axisNameID;

    /**
        The axis should not be exposed directly in user interfaces.
    */
    bool isHiddenAxis() {
        return (flags & 0x0001) == 0x0001;
    }
}

struct FVarInstanceRecord {
@nogc:
    
    /**
        The name ID for entries in the 'name' table that provide 
        subfamily names for this instance.
    */
    ushort subfamilyNameId;
    
    /**
        Reserved for future use — set to 0.
    */
    ushort flags;
    
    /**
        Coordinate array specifying a position within the font’s variation space.
    */
    fixed32[] coordinates;
    
    /**
        Optional

        The name ID for entries in the 'name' table that provide 
        PostScript names for this instance.
    */
    ushort postScriptNameId;

    void free() {
        ha_freearr(coordinates);
    }

    void deserialize(SFNTReader reader, uint axisCount) {
        this.subfamilyNameId = reader.readElementBE!ushort;
        this.flags = reader.readElementBE!ushort;

        this.coordinates = ha_allocarr!fixed32(axisCount);
        reader.readElementsBE(this.coordinates);

        this.postScriptNameId = reader.readElementBE!ushort;
    }
}