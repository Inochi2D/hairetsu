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
    
    ptrdiff_t getOffset(GlyphIndex index) {
        if (auto table = entry.findTable(ISO15924!("loca"))) {
            reader.seek(entry.offset+table.offset);

            if (head.indexToLocFormat == 1) {
                reader.skip(index*4);
                return reader.readElementBE!uint();
            }

            reader.skip(index*2);
            return reader.readElementBE!uint();
        }
        return -1;
    }

    TTGlyfHeader getGlyphHeader(GlyphIndex index) {
        ptrdiff_t gHeaderOffset = getOffset(index);

        if (auto table = entry.findTable(ISO15924!("glyf"))) {
            reader.seek(entry.offset+table.offset+gHeaderOffset);
            return reader.readRecord!TTGlyfHeader();
        }

        return TTGlyfHeader.init;
    }

protected:

    override
    HaFontFace onCreateFace(HaFontReader reader) {
        return nogc_new!TTFontFace(this, reader);
    }


public:
    
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
        TTGlyfHeader header = getGlyphHeader(glyph);

        metrics.size.x = (header.xMax - header.xMin);
        metrics.size.y = (header.yMax - header.yMin);

        // TODO: Query baseline variations, etc.
        return metrics;
    }
}

