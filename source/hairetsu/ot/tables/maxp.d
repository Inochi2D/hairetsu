/**
    OpenType Maxp Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/hmtx
*/
module hairetsu.ot.tables.maxp;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    MAXP table
*/
struct MaxpTable {
@nogc:
    
    /**
        Table version
    */
    fixed32 version_;
    
    /**
        The number of glyphs in the font.
    */
    ushort numGlyphs;
    
    /**
        Maximum points in a non-composite glyph.
    */
    ushort maxPoints;
    
    /**
        Maximum contours in a non-composite glyph.
    */
    ushort maxContours;
    
    /**
        Maximum points in a composite glyph.
    */
    ushort maxCompositePoints;
    
    /**
        Maximum contours in a composite glyph.
    */
    ushort maxCompositeContours;
    
    /**
        1 if instructions do not use the twilight zone (Z0), 
        or 2 if instructions do use Z0; should be set to 2 in most cases.
    */
    ushort maxZones;
    
    /**
        Maximum points used in Z0.
    */
    ushort maxTwilightPoints;
    
    /**
        Number of Storage Area locations.
    */
    ushort maxStorage;
    
    /**
        Number of FDEFs, equal to the highest function number + 1.
    */
    ushort maxFunctionDefs;
    
    /**
        Number of IDEFs.
    */
    ushort maxInstructionDefs;
    
    /**
        Maximum stack depth across Font Program ('fpgm' table), 
        CVT Program ('prep' table) and all glyph 
        instructions (in the 'glyf' table).
    */
    ushort maxStackElements;
    
    /**
        Maximum byte count for glyph instructions.
    */
    ushort maxSizeOfInstructions;
    
    /**
        Maximum number of components referenced at “top level” 
        for any composite glyph.
    */
    ushort maxComponentElements;
    
    /**
        Maximum levels of recursion; 1 for simple components.
    */
    ushort maxComponentDepth;

    void deserialize(FontReader reader) {
        this.version_ = reader.readElementBE!fixed32;
        this.numGlyphs = reader.readElementBE!ushort;

        if (version_ == 0.5) {
            this.maxPoints = reader.readElementBE!ushort;
            this.maxContours = reader.readElementBE!ushort;
            this.maxCompositePoints = reader.readElementBE!ushort;
            this.maxCompositeContours = reader.readElementBE!ushort;
            this.maxZones = reader.readElementBE!ushort;
            this.maxTwilightPoints = reader.readElementBE!ushort;
            this.maxStorage = reader.readElementBE!ushort;
            this.maxFunctionDefs = reader.readElementBE!ushort;
            this.maxInstructionDefs = reader.readElementBE!ushort;
            this.maxStackElements = reader.readElementBE!ushort;
            this.maxSizeOfInstructions = reader.readElementBE!ushort;
            this.maxComponentElements = reader.readElementBE!ushort;
            this.maxComponentDepth = reader.readElementBE!ushort;
        }
    }
}