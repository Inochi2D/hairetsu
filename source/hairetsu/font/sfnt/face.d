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
import std.regex;

import hairetsu.font.tables.glyf;



/**
    A SFNT-derived font face.
*/
abstract
class SFNTFontFace : FontFace {
private:
@nogc:

    //
    //      Outlines
    //
    bool hasOutline(ref Glyph glyph) {
        return parent.getGlyphHasOutline(glyph.index); 
    }

    GlyphOutline getOutline(ref Glyph glyph) {
        SFNTFont sfnt = (cast(SFNTFont)parent);

        GlyphStoreType types = sfnt.glyphTypes();
        if (types & GlyphStoreType.trueType) {
            if (sfnt.hasGlyfOutline(glyph.index))
                return getTTFOutline(glyph);
        }

        return GlyphOutline.init;
    }

    //
    //      TrueType Outlines
    //

    GlyphOutline getTTFOutline(ref Glyph glyph) {
        GlyphOutline outline;

        float fscale = cast(float)scale;
        GlyfRecord record = (cast(SFNTFont)parent).getGlyfRecord(glyph.index);
        GlyfPoint start;
        GlyfPoint first;
        GlyfPoint last;
        GlyfPoint curr;
        import std.stdio : printf;

        foreach(ref GlyfContour contour; record.contours) {
            if (contour.points.length == 0)
                continue;
            size_t ci = outline.commands.length;

            foreach(i; 0..contour.points.length) {
                last = curr;
                curr = contour.points[i];
                
                // Calculate absolute point
                curr.point.x = last.point.x + (curr.point.x * fscale);
                curr.point.y = last.point.y - (curr.point.y * fscale);
                
                if (i == 0) {
                    start = curr;
                    outline.moveTo(start.point);
                    continue;
                }

                // First dst.
                if (i == 1) {
                    first = curr;
                }

                if (last.onCurve && curr.onCurve) {
                    outline.lineTo(curr.point);
                } else if (!last.onCurve || curr.onCurve) {

                    // Target point for quad spline.
                    vec2 tgt = curr.onCurve ?
                        curr.point :
                        last.point.midpoint(curr.point);

                    outline.quadTo(last.point, tgt);
                }
            }

            if (start.onCurve ^ curr.onCurve) {

                // Target point for quad spline.
                vec2 tgt = curr.onCurve ?
                    start.point :
                    curr.point.midpoint(start.point);

                outline.quadTo(curr.point, tgt);
            } else if (!start.onCurve && !curr.onCurve) {

                // Target-to-first
                vec2 p1 = curr.point.midpoint(start.point);
                vec2 p2 = start.point.midpoint(first.point);

                outline.quadTo(curr.point, p1);
                outline.quadTo(start.point, p2);
            }

            outline.closePath();
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
    void onRenderGlyph(FontReader reader, ref Glyph glyph) {
        glyph.setOutline(glyph.index, this.getOutline(glyph));
    }
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(FontReader reader) {        
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
    this(Font parent, FontReader reader) {
        super(parent, reader);
    }
}