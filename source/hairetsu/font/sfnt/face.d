/**
    Hairetsu SFNT Face Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.face;
import hairetsu.font.sfnt.font;
import hairetsu.font.sfnt.reader;
import hairetsu.font.tt.types;
import hairetsu.font.ot.types;
import hairetsu.font.reader;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.common;
import hairetsu.glyph;

import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;



/**
    A SFNT-derived font face.
*/
abstract
class SFNTFontFace : HaFontFace {
private:
@nogc:

    //
    //      Outlines
    //
    HaGlyphOutline getOutline(ref HaGlyph glyph) {
        SFNTFont sfnt = (cast(SFNTFont)parent);

        SFNTOutlineType types = sfnt.outlineTypes();
        if (types & SFNTOutlineType.trueType) {
            if (sfnt.hasGlyfOutline(glyph.index))
                return getTTFOutline(glyph);
        }

        return HaGlyphOutline.init;
    }

    //
    //      TrueType Outlines
    //

    HaGlyphOutline getTTFOutline(ref HaGlyph glyph) {
        HaGlyphOutline outline;

        TTGlyfTable gtable = (cast(SFNTFont)parent).getGlyfTable(glyph.index);
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
        The reader instance
    */
    SFNTReader reader;

    /**
        Implemented by a font face to load a glyph.
    */
    override
    void onRenderGlyph(HaFontReader reader, ref HaGlyph glyph) {
        glyph.setOutline(glyph.index, this.getOutline(glyph));
    }
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(HaFontReader reader) {        
        this.reader = cast(SFNTReader)reader;
    }
    
public:
    
    /**
        The font entry.
    */
    final
    @property SFNTFontEntry entry() { return (cast(SFNTFont)parent).entry; }

    /**
        Constructs a font face.
    */
    this(HaFont parent, HaFontReader reader) {
        super(parent, reader);
    }
}