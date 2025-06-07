/**
    OpenType Glyf Table.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: 
        https://learn.microsoft.com/en-us/typography/opentype/spec/glyf
        https://learn.microsoft.com/en-us/typography/opentype/spec/loca
*/
module hairetsu.font.tables.glyf;
import hairetsu.font.tables.common;
import hairetsu.font.sfnt.reader;
import hairetsu.font.tables.head;
import hairetsu.font.tables.maxp;
import hairetsu.font.glyph;

/**
    The glyf table
*/
struct GlyfTable {
@nogc:
    GlyfRecord[] glyphs;

    /**
        Gets whether a given glyph ID has an outline.
    */
    pragma(inline, true)
    bool hasGlyph(GlyphIndex glyphId) {
        return glyphId < glyphs.length ? glyphs[glyphId].hasOutline : false;
    }

    /**
        Tries to find the specified glyph within the table.
    */
    pragma(inline, true)
    GlyfRecord* findGlyf(GlyphIndex glyphId) {
        if (glyphId >= glyphs.length)
            return null;
        
        return &glyphs[glyphId];
    }

    /**
        Frees the glyf table
    */
    void free() {
        ha_freearr(this.glyphs);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(SFNTReader reader, ref LocaTable loca) {
        size_t start = reader.tell();

        this.glyphs = ha_allocarr!GlyfRecord(loca.offsets.length);
        foreach(i; 0..glyphs.length) {
            GlyphIndex glyphId = cast(GlyphIndex)i;

            reader.seek(start+loca.offsets[glyphId]);
            this.glyphs[i].deserialize(reader, glyphId, loca.hasGlyph(glyphId));
        }
    }
}

/**
    Drawing data passed into glyf.
*/
struct GlyfDrawData {
@nogc:
    GlyfRecord* record;
    GlyphDrawCallbacks* callbacks;
}

/**
    Internal draw function which passes the render callbacks
    into the glyf handler.

    You won't use this directly.
*/
extern(C)
bool __ha_glyf_draw_function(void*[4] argHandles, float scale, void* userdata) @nogc {
    GlyfRecord* record = cast(GlyfRecord*)argHandles[0];
    GlyphDrawCallbacks* callbacks = cast(GlyphDrawCallbacks*)argHandles[1];
    
    if (record && callbacks) {
        record.drawWith(*callbacks, scale, userdata);
        return true;
    }
    return false;
}

/**
    A single glyf record.
*/
struct GlyfRecord {
public:
@nogc:
    bool isComposite;
    GlyfContour[] contours;
    GlyphIndex glyphId;
    rect bounds;

    /**
        Whether the glyph has an outline.
    */
    bool hasOutline() {
        return contours.length > 0;
    }

    /**
        Frees the glyf record
    */
    void free() {
        ha_freearr(contours);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(SFNTReader reader, GlyphIndex glyphId, bool hasOutlines) {
        short numberOfCountours = reader.readElementBE!short;
        short xMin = reader.readElementBE!short;
        short yMin = reader.readElementBE!short;
        short xMax = reader.readElementBE!short;
        short yMax = reader.readElementBE!short;
        
        // Base info
        this.glyphId = glyphId;
        this.bounds = rect(xMin, xMax, yMin, yMax);

        // The outline is detected by the glyph offset not having changed
        // therefore we want to avoid loading another glyph's outline.
        if (!hasOutlines)
            return;

        // Contours
        if (numberOfCountours >= 0) {
            this.isComposite = false;
            SimpleGlyfContour simpleContour;
            simpleContour.deserialize(reader, numberOfCountours);

            this.contours = ha_allocarr!GlyfContour(numberOfCountours);
            foreach(i; 0..contours.length) {
                uint start = i == 0 ? 0 : simpleContour.endPtsOfContours[i-1]+1;
                uint end = simpleContour.endPtsOfContours[i]+1;
                
                this.contours[i].parse(simpleContour, start, end-start);
            }

            simpleContour.free();
            return;
        }

        this.isComposite = true;
    }

    /**
        Draws the glyf with the given callbacks.
        
        Params:
            outline = The outline drawing callbacks to call.
            scale = The scale to apply to the outline.
            userdata = Userdata to pass to drawing functions.
    */
    void drawWith(GlyphDrawCallbacks outline, float scale, void* userdata) {
        
        // NOTE: Temporary stores needed to calculate outliens from the
        //       compressed form, start and first differ due to how outlines
        //       can start and end with off-curve points; in which case you need
        //       to use the point after the first to calculate the ghost control point. 
        GlyfPoint start;
        GlyfPoint first;
        GlyfPoint last;
        GlyfPoint curr;

        foreach(ref GlyfContour contour; contours) {
            
            // Skip empty contours.
            if (contour.points.length == 0)
                continue;
            
            foreach(i; 0..contour.points.length) {
                last = curr;
                curr = contour.points[i];
                
                // Calculate absolute point
                curr.point.x = last.point.x + (curr.point.x * scale);
                curr.point.y = last.point.y - (curr.point.y * scale);
                
                if (i == 0) {
                    start = curr;
                    outline.moveTo(start.point.x, start.point.y, userdata);
                    continue;
                }

                // First dst.
                if (i == 1) {
                    first = curr;
                }

                if (last.onCurve && curr.onCurve) {
                    outline.lineTo(curr.point.x, curr.point.y, userdata);
                } else if (!last.onCurve || curr.onCurve) {

                    // Target point for quad spline.
                    vec2 tgt = curr.onCurve ?
                        curr.point :
                        last.point.midpoint(curr.point);

                    outline.quadTo(last.point.x, last.point.y, tgt.x, tgt.y, userdata);
                }
            }

            if (start.onCurve ^ curr.onCurve) {

                // Target point for quad spline.
                vec2 tgt = curr.onCurve ?
                    start.point :
                    curr.point.midpoint(start.point);

                outline.quadTo(curr.point.x, curr.point.y, tgt.x, tgt.y, userdata);
            } else if (!start.onCurve && !curr.onCurve) {

                // Target-to-first
                vec2 p1 = curr.point.midpoint(start.point);
                vec2 p2 = start.point.midpoint(first.point);

                outline.quadTo(curr.point.x, curr.point.y, p1.x, p1.y, userdata);
                outline.quadTo(start.point.x, start.point.y, p2.x, p2.y, userdata);
            }

            outline.closePath(userdata);
        }
    }
}

/**
    A glyph contour
*/
struct GlyfContour {
@nogc:
    GlyfPoint[] points;

    void free() {
        ha_freearr(points);
    }

    /**
        Deserializes the Glyf table
    */
    void parse(ref SimpleGlyfContour contour, uint start, uint length) {
        this.points = ha_allocarr!GlyfPoint(length);
        foreach(i; 0..length) {
            this.points[i] = GlyfPoint(
                point: contour.contours[start+i],
                onCurve: (contour.flags[start+i] & ON_CURVE_POINT)
            );
        }
    }
}

/**
    A point in a glyph contour
*/
struct GlyfPoint {
    vec2 point;
    bool onCurve;
}

/// Only used internally to construct GlyfContour
struct SimpleGlyfContour {
@nogc:
    ushort[] endPtsOfContours;
    ubyte[] instructions;
    ubyte[] flags;
    vec2[] contours;

    void free() {
        ha_freearr(endPtsOfContours);
        ha_freearr(instructions);
        ha_freearr(flags);
        ha_freearr(contours);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(SFNTReader reader, ushort contourCount) {
        
        // endPtsOfContours
        this.endPtsOfContours = ha_allocarr!ushort(contourCount);
        reader.readElementsBE!ushort(endPtsOfContours);

        // instructions
        ushort instructionLength = reader.readElementBE!ushort;
        if (instructionLength > 0) {
            this.instructions = ha_allocarr!ubyte(instructionLength);
            reader.read(instructions);
        }

        ushort pointCount = cast(ushort)(endPtsOfContours[$-1]+1);
        if (pointCount > 0) {
            this.flags = ha_allocarr!ubyte(pointCount);
            this.contours = ha_allocarr!vec2(pointCount);

            // Read and expand flags
            for (size_t i = 0; i < pointCount; i++) {
                ubyte flag = reader.readElementBE!ubyte;
                flags[i] = flag;

                if (flag & REPEAT_FLAG) {
                    ubyte repeat = reader.readElementBE!ubyte;
                    foreach(_; 0..repeat) {
                        if (i+1 >= pointCount) break;

                        flags[++i] = flag;
                    }
                }
            }


            // Read X coordinates
            for (size_t i = 0; i < pointCount; i++) {
                int coordinate;
                ubyte flag = flags[i];
                bool sameOrSign = (flag & X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR) > 0;

                if (flag & X_SHORT_VECTOR) {
                    coordinate = sameOrSign ? 
                        reader.readElementBE!ubyte :
                        -(cast(int)reader.readElementBE!ubyte);
                } else {
                    coordinate = sameOrSign ? 
                        0 : // No change
                        reader.readElementBE!short;
                }

                contours[i].x = coordinate;
            }

            // Read Y coordinates
            for (size_t i = 0; i < pointCount; i++) {
                int coordinate;
                ubyte flag = flags[i];
                bool sameOrSign = (flag & Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR) > 0;

                if (flag & Y_SHORT_VECTOR) {
                    coordinate = sameOrSign ? 
                        reader.readElementBE!ubyte :
                        -(cast(int)reader.readElementBE!ubyte);
                } else {
                    coordinate = sameOrSign ? 
                        0 : // No change
                        reader.readElementBE!short;
                }

                contours[i].y = coordinate;
            }
        }
    }
}

private
enum ubyte 
    ON_CURVE_POINT                          = 0x01,
    X_SHORT_VECTOR                          = 0x02,
    Y_SHORT_VECTOR                          = 0x04,
    REPEAT_FLAG                             = 0x08,
    X_IS_SAME_OR_POSITIVE_X_SHORT_VECTOR    = 0x10,
    Y_IS_SAME_OR_POSITIVE_Y_SHORT_VECTOR    = 0x20,
    OVERLAP_SIMPLE                          = 0x40;


struct LocaTable {
@nogc:
    uint[] offsets;

    /**
        Whether the glyph at the given offset has an outline.
    */
    bool hasGlyph(uint glyphId) {
        if (glyphId+1 >= offsets.length)
            return false;

        return offsets[glyphId] != offsets[glyphId+1];
    }

    /**
        Frees the Loca Table
    */
    void free() {
        this.offsets = offsets.nu_resize(0);
    }

    /**
        Deserializes the Loca table.
    */
    void deserialize(SFNTReader reader, HeadTable head, MaxpTable maxp) {
        switch(head.indexToLocFormat) {
            case 0:
                this.offsets = offsets.nu_resize(maxp.numGlyphs+1);
                foreach(i; 0..offsets.length) {
                    this.offsets[i] = (cast(uint)reader.readElementBE!ushort())*2;
                }
                return;

            case 1:
                this.offsets = offsets.nu_resize(maxp.numGlyphs+1);
                reader.readElementsBE!uint(this.offsets);
                return;
            
            default:
                return;
        }
    }
}
