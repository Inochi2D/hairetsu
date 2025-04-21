/**
    Hairetsu TrueType Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.font;
import hairetsu.font.tt.face;
import hairetsu.font.tt.types;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.glyph;
import nulib.collections;
import numem;

import hairetsu.font.font : HaFont;
import hairetsu.common;

/**
    A TrueType font
*/
class TTFont : SFNTFont {
private:
@nogc:
    
    ptrdiff_t getOffset(GlyphIndex index, ref bool hasOutlines) {
        if (auto table = entry.findTable(ISO15924!("loca"))) {
            reader.seek(entry.offset+table.offset);

            if (head.indexToLocFormat == 1) {
                reader.skip(index*4);
                uint f0 = reader.readElementBE!uint();
                uint f1 = reader.readElementBE!uint();

                hasOutlines = f0 != f1;
                return f0;
            }

            reader.skip(index*2);
            ushort f0 = reader.readElementBE!ushort();
            ushort f1 = reader.readElementBE!ushort();
            hasOutlines = f0 != f1;
            return f0;
        }
        return -1;
    }

    TTGlyfTableHeader getGlyphHeader(GlyphIndex index) {
        bool hasOutlines;
        ptrdiff_t gHeaderOffset = getOffset(index, hasOutlines);

        if (auto table = entry.findTable(ISO15924!("glyf"))) {
            reader.seek(entry.offset+table.offset+gHeaderOffset);
            return reader.readRecord!TTGlyfTableHeader();
        }

        return TTGlyfTableHeader.init;
    }

protected:

    override
    HaFontFace onCreateFace(HaFontReader reader) {
        return nogc_new!TTFontFace(this, reader);
    }


public:

    /**
        Reads the Glyf table.
    */
    TTGlyfTable getGlyphTable(GlyphIndex index) {
        bool hasOutlines;
        ptrdiff_t gHeaderOffset = getOffset(index, hasOutlines);

        if (auto table = entry.findTable(ISO15924!("glyf"))) {
            reader.seek(entry.offset+table.offset+gHeaderOffset);

            if (hasOutlines)
                return reader.readRecord!TTGlyfTable();

            // No outlines, clear contours.
            auto header = reader.readRecord!TTGlyfTableHeader();
            header.numberOfCountours = 0;
            return TTGlyfTable(header: header);
        }

        return TTGlyfTable.init;
    }
    
    /**
        Constructs a new font face from a stream.
    */
    this(SFNTFontEntry entry, HaFontReader reader) {
        super(entry, reader);
    }

    /**
        The name of the type of font.
    */
    override @property string type() { return "TrueType"; }

    
    override
    HaGlyphMetrics getMetricsFor(GlyphIndex glyph) {
        HaGlyphMetrics metrics = super.getMetricsFor(glyph);
        TTGlyfTableHeader header = getGlyphHeader(glyph);

        metrics.size.x = (header.xMax - header.xMin);
        metrics.size.y = (header.yMax - header.yMin);

        // TODO: Query baseline variations, etc.
        return metrics;
    }
}

