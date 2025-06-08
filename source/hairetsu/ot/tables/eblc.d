/**
    OpenType EBLC Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/eblc
*/
module hairetsu.ot.tables.eblc;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    Embedded Bitmap Location Table
*/
struct EBLCTable {
public:
@nogc:
    BitmapSizeRecord[] sizes;

    /**
        Finds size record associated with the given glyph.

        Params:
            glyph = The glyph to look for.
        
        Returns:
            A bitmap size record for the glyph.
    */
    BitmapSizeRecord findGlyphSizeRecord(GlyphIndex glyph) {
        foreach(ref BitmapSizeRecord size; sizes) {
            if (size.startGlyphIndex >= glyph && size.startGlyphIndex <= glyph)
                return size;
        }

        return BitmapSizeRecord.init;
    }

    /**
        Frees the EBLC table.
    */
    void free() {
        ha_freearr(sizes);
    }
    
    /**
        Deserializes the EBLC table.
    */
    void deserialize(SFNTReader reader) { }
}

struct BitmapSizeRecord {
public:
@nogc:
    uint indexSubtableListOffset;
    uint indexSubtableListSize;
    uint numberOfIndexSubtables;
    SbitLineMetrics hori;
    SbitLineMetrics verti;
    ushort startGlyphIndex;
    ushort endGlyphIndex;
    ubyte ppemX;
    ubyte ppemY;
    ubyte bitDepth;
    ubyte flags;

    /**
        Deserializes the size record.
    */
    void deserialize(SFNTReader reader) {
        
    }

    /**
        Whether the glyph metrics are horizontal.
    */
    pragma(inline, true)
    bool isHorizontal() nothrow pure { return (flags & 0x01) == 0x01; }

    /**
        Whether the glyph metrics are vertical.
    */
    pragma(inline, true)
    bool isVertical() nothrow pure { return (flags & 0x02) == 0x02; }
}

/**
    Sbit Glyph Metrics
*/
struct SbitGlyphMetrics {
public:
@nogc:
    
    /**
        Size of glyph in pixels.
    */
    vec2i size;
    
    /**
        Advance of glyph in pixels.
    */
    vec2 advance;
    
    /**
        Horizontal bearing of glyph in pixels.
    */
    vec2 hBearing;
    
    /**
        Vertical bearing of glyph in pixels.
    */
    vec2 vBearing;
    
    /**
        Parses small metrics format from a reader.
    */
    void parseSmall(SFNTReader reader) {
        size.y = reader.readElementBE!ubyte;
        size.x = reader.readElementBE!ubyte;
        hBearing.x = cast(float)reader.readElementBE!byte;
        hBearing.y = cast(float)reader.readElementBE!byte;
        advance.x = cast(float)reader.readElementBE!ubyte;
    }

    /**
        Parses big metrics format from a reader.
    */
    void parseBig(SFNTReader reader) {
        size.y = reader.readElementBE!ubyte;
        size.x = reader.readElementBE!ubyte;
        hBearing.x = cast(float)reader.readElementBE!byte;
        hBearing.y = cast(float)reader.readElementBE!byte;
        advance.x = cast(float)reader.readElementBE!ubyte;
        vBearing.x = cast(float)reader.readElementBE!byte;
        vBearing.y = cast(float)reader.readElementBE!byte;
        advance.y = cast(float)reader.readElementBE!ubyte;
    }
}

/**
    Sbit Line metrics
*/
struct SbitLineMetrics {
public:
@nogc:
    
    /**
        Ascender in pixels.
    */
    float ascender;
    
    /**
        Descender in pixels.
    */
    float descender;

    /**
        Max width in pixels.
    */
    uint widthMax;

    /**
        Angle at which the caret should be drawn.
    */
    float caretSlope;

    /**
        Offset of the caret in pixels.
    */
    float caretOffset;

    /**
        Baseline bearing origin in pixels.
    */
    float minOriginSB;
    
    /**
        Baseline advance in pixels.
    */
    float minAdvanceSB;
    
    /**
        Baseline start of glyph in pixels.
    */
    float maxBeforeBL;
    
    /**
        Baseline end of glyph in pixels.
    */
    float minAfterBL;
    
    /**
        Parses small metrics format from a reader.
    */
    void deserialize(SFNTReader reader) {
        this.ascender = reader.readElementBE!byte();
        this.descender = reader.readElementBE!byte();
        this.widthMax = reader.readElementBE!ubyte();

        // Caret
        byte numer = reader.readElementBE!byte;
        byte denom = reader.readElementBE!byte;
        this.caretSlope = cast(float)numer / cast(float)denom;
        this.caretOffset = reader.readElementBE!byte;

        // Baseline metrics
        this.minOriginSB = reader.readElementBE!byte;
        this.minAdvanceSB = reader.readElementBE!byte;
        this.maxBeforeBL = reader.readElementBE!byte;
        this.minAfterBL = reader.readElementBE!byte;

        // Padding bytes.
        reader.skip(2);
    }
}