/**
    OpenType Hhea Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/hhea
*/
module hairetsu.ot.tables.hhea;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Horizontal Header Table
*/
struct HheaTable {
@nogc:
    
    /**
        Major version number of the horizontal header table — set to 1.
    */
    ushort majorVersion;
    
    /**
        Minor version number of the horizontal header table — set to 0.
    */
    ushort minorVersion;
    
    /**
        Typographic ascent
    */
    short ascender;
    
    /**
        Typographic descent
    */
    short descender;
    
    /**
        Typographic line gap.
        
        Negative lineGap values are treated as zero in some legacy platform implementations.
    */
    short lineGap;
    
    /**
        Maximum advance width value in 'hmtx' table.
    */
    ushort advanceWidthMax;
    
    /**
        Minimum left sidebearing value in 'hmtx' table for glyphs 
        with contours (empty glyphs should be ignored).
    */
    short minLeftSideBearing;
    
    /**
        Minimum right sidebearing value; calculated as min(aw - (lsb + xMax - xMin)) for 
        glyphs with contours (empty glyphs should be ignored).
    */
    short minRightSideBearing;
    
    /**
        Max(lsb + (xMax - xMin)).
    */
    short xMaxExtent;
    
    /**
        Used to calculate the slope of the cursor (rise/run); 
        
        1 for vertical.
    */
    short caretSlopeRise;
    
    /**
        0 for vertical.
    */
    short caretSlopeRun;
    
    /**
        The amount by which a slanted highlight on a glyph needs to be 
        shifted to produce the best appearance. 
        
        Set to 0 for non-slanted fonts.
    */
    short caretOffset;

    /// Reserved.
    short reserved0;
    
    /// ditto
    short reserved1;
    
    /// ditto
    short reserved2;
    
    /// ditto
    short reserved3;
    
    /**
        0 for current format.
    */
    short metricDataFormat;
    
    /**
        Number of hMetric entries in 'hmtx' table
    */
    short numberOfHMetrics;
}
