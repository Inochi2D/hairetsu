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
import std.regex;



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
    bool hasOutline(ref HaGlyph glyph) {
        SFNTFont sfnt = (cast(SFNTFont)parent);
        return sfnt.hasGlyfOutline(glyph.index); 
    }

    HaGlyphOutline getOutline(ref HaGlyph glyph) {
        SFNTFont sfnt = (cast(SFNTFont)parent);

        HaGlyphStoreType types = sfnt.glyphTypes();
        if (types & HaGlyphStoreType.trueType) {
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
            float fscale = cast(float)scale;

            // Start-end state.
            bool startOnCurve;
            ubyte startFlag;
            vec2 startPen;
            vec2 firstPen;
            bool endOnCurve;
            ubyte endFlag;
            vec2 endPen;

            // Current state.
            size_t rptr;
            ubyte lastFlag;
            ubyte flag;
            vec2 offset;
            vec2 lastPen;
            vec2 pen;

            // Construct font outline.
            mloop: foreach(ushort endpoint; gtable.simple.endPtsOfContours[]) {
                bool firstFound = false;
                size_t lptr = 0;
                do {
                    if (rptr >= gtable.simple.contours.length)
                        break mloop;

                    lastFlag = flag;
                    lastPen = pen;
                    offset = gtable.simple.contours[rptr];
                    flag = gtable.simple.flags[rptr];

                    // Figure out pen positions.
                    pen.x = lastPen.x + (offset.x * fscale);
                    pen.y = lastPen.y - (offset.y * fscale);

                    bool onCurve = (flag & ON_CURVE_POINT);

                    // Handle first position.
                    if (lptr == 0) {
                        outline.moveTo(pen);
                        startOnCurve = onCurve;
                        startFlag = flag;
                        startPen = pen;

                        if (onCurve) {
                            firstPen = pen;
                            firstFound = true;
                        }

                        lastFlag = flag;
                        lastPen = pen;
                        
                        endPen = pen;
                        endFlag = flag;
                        endOnCurve = (endFlag & ON_CURVE_POINT);
                        lptr++;
                        rptr++;
                        continue;
                    }

                    if (!firstFound) {
                        firstPen = pen;
                        firstFound = true;
                    }
                    
                    // Handle some of the intricacies of the quadratic curves by
                    // shifting them a bit with a lerp.
                    vec2 pen2 = onCurve ? 
                        pen : 
                        lastPen.midpoint(pen);

                    if (endOnCurve && onCurve) {
                        outline.lineTo(pen2);
                    } else if (!endOnCurve || onCurve) {
                        outline.quadTo(lastPen, pen2);
                    }

                    lptr++; 
                    rptr++;
                    endPen = pen;
                    endFlag = flag;
                    endOnCurve = (endFlag & ON_CURVE_POINT);
                } while(rptr <= endpoint);

                if (startOnCurve ^ endOnCurve) {
                    vec2 pen2 = firstPen;
                    vec2 ctrl = endOnCurve ? startPen : endPen;
                    outline.quadTo(ctrl, pen2);
                } else if (!startOnCurve && !endOnCurve) {
                    vec2 ctrl = lerp(pen, startPen, 0.5);
                    outline.quadTo(ctrl, startPen);
                }

                outline.closePath();
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