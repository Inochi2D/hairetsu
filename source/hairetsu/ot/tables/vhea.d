/**
    OpenType Vhea Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/hhea
*/
module hairetsu.ot.tables.vhea;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Vertical Header Table
*/
struct VheaTable {
@nogc:
    
    /**
        Version number of the vertical header table; 0x00010000 for version 1.0
    */
    fixed32 version_;
    
    /**
        Distance in font design units from the centerline to the previous line’s descent.
    */
    short ascender;
    
    /**
        Distance in font design units from the centerline to the next line’s ascent.
    */
    short descender;
    
    /**
        Reserved; set to 0
    */
    short lineGap;
    
    /**
        The maximum advance height measurement in font design units found in the font. 
        
        This value must be consistent with the entries in the vertical metrics table.
    */
    ushort advanceHeightMax;
    
    /**
        The minimum top sidebearing measurement found in the font, in font design units.
        
        This value must be consistent with the entries in the vertical metrics table.
    */
    short minTopSideBearing;
    
    /**
        The minimum bottom sidebearing measurement found in the font, in font design units.
        
        This value must be consistent with the entries in the vertical metrics table.
    */
    short minBottomSideBearing;
    
    /**
        Defined as yMaxExtent = max(tsb + (yMax - yMin)).
    */
    short yMaxExtent;
    
    /**
        The value of the caretSlopeRise field divided by the value of the caretSlopeRun Field 
        determines the slope of the caret.
        A value of 0 for the rise and a value of 1 for the run specifies a horizontal caret.
        A value of 1 for the rise and a value of 0 for the run specifies a vertical caret.
        Intermediate values are desirable for fonts whose glyphs are oblique or italic.
        For a vertical font, a horizontal caret is best.
    */
    short caretSlopeRise;
    
    /**
        See the caretSlopeRise field. Value=1 for nonslanted vertical fonts.
    */
    short caretSlopeRun;
    
    /**
        The amount by which the highlight on a slanted glyph needs to be 
        shifted away from the glyph in order to produce the best appearance.
        Set value equal to 0 for nonslanted fonts.
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
        Set to 0.
    */
    short metricDataFormat;
    
    /**
        Number of advance heights in the vertical metrics table.
    */
    short numberOfVMetrics;
}
