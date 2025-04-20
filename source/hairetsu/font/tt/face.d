/**
    Hairetsu TrueType Font Face

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.tt.face;
import hairetsu.font.tt.font;
import hairetsu.font.tt.types;
import hairetsu.font.reader;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.glyph;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

import hairetsu.common;

/**
    OpenType CFF/CFF2 font face.
*/
class TTFontFace : HaFontFace {
private:
@nogc:

    HaGlyphOutline computeOutlineNoHinting(ref HaGlyph glyph) {
        HaGlyphOutline outline;

        TTGlyfTable gtable = (cast(TTFont)parent).getGlyphTable(glyph.index);
        if (gtable.header.numberOfCountours > 0) {
            TTSimpleGlyphRecord* simple = &gtable.simple;
            float fscale = cast(float)scale;

            size_t rptr;
            ubyte lastFlag;
            HaVec2!float lastPen;
            HaVec2!float pen;

            // Construct font outline.
            foreach(ref ushort endpoint; gtable.simple.endPtsOfContours[]) {
                size_t lptr = 0;
                do {
                    HaVec2!float offset = simple.contours[rptr];
                    ubyte flag = simple.flags[rptr];

                    pen.x = lastPen.x + (offset.x * fscale);
                    pen.y = lastPen.y - (offset.y * fscale);
                    if (lptr == 0) {
                        outline.moveTo(pen);
                        lastFlag = flag;
                        lastPen = pen;
                        lptr++;
                        rptr++;
                        continue;
                    }
                    

                    if ((lastFlag & ON_CURVE_POINT) && (flag & ON_CURVE_POINT)) {
                        outline.lineTo(pen);
                    } else {
                        outline.quadTo(lastPen, pen);
                    }

                    lastFlag = flag;
                    lastPen = pen;
                    lptr++; 
                    rptr++;
                } while(rptr <= endpoint);
            }
        }
        return outline;
    }

protected:

    /**
        Implemented by a font face to load a glyph.
    */
    override
    void onRenderGlyph(HaFontReader reader, ref HaGlyph glyph) {
        glyph.setOutline(glyph.index, this.computeOutlineNoHinting(glyph));
    }
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(HaFontReader reader) { }
    
public:

    /**
        Constructs a font face.
    */
    this(HaFont parent, HaFontReader reader) {
        super(parent, reader, false);
    }
}