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
module hairetsu.ot.tables.glyf;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;
import hairetsu.ot.tables.head;
import hairetsu.ot.tables.maxp;
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
        nu_freea(this.glyphs);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(FontReader reader, ref LocaTable loca) {
        size_t start = reader.tell();

        this.glyphs = nu_malloca!GlyfRecord(loca.offsets.length);
        foreach(i; 0..glyphs.length) {
            GlyphIndex glyphId = cast(GlyphIndex)i;

            reader.seek(start+loca.offsets[glyphId]);
            this.glyphs[i].deserialize(reader, glyphId, loca.hasGlyph(glyphId));
            this.glyphs[i].glyf = &this;
        }
    }
}

/**
    A single glyf record.
*/
struct GlyfRecord {
public:
@nogc:
    GlyfTable* glyf;
    GlyfContour[] contours;
    GlyfComposite[] composites;
    GlyphIndex glyphId;
    rect bounds;

    /**
        Whether the contour is a composite.
    */
    @property bool isComposite() { return composites.length > 0; }

    /**
        Whether the glyph has an outline.
    */
    bool hasOutline() { return contours.length > 0 || composites.length > 0; }

    /**
        Frees the glyf record
    */
    void free() {
        nu_freea(contours);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(FontReader reader, GlyphIndex glyphId, bool hasOutlines) {
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
            SimpleGlyfContour simpleContour;
            simpleContour.deserialize(reader, numberOfCountours);

            this.contours = nu_malloca!GlyfContour(numberOfCountours);
            foreach(i; 0..contours.length) {
                uint start = i == 0 ? 0 : simpleContour.endPtsOfContours[i-1]+1;
                uint end = simpleContour.endPtsOfContours[i]+1;
                
                this.contours[i].parse(simpleContour, start, end-start);
            }

            simpleContour.free();
            return;
        } else {
            GlyfComposite composite;
            do {
                composite.flags = reader.readElementBE!ushort();
                composite.glyphIndex = reader.readElementBE!ushort();

                if (composite.flags & ARG_1_AND_2_ARE_WORDS) {
                    if (composite.flags & ARGS_ARE_XY_VALUES) {
                        composite.position.x = reader.readElementBE!short();
                        composite.position.y = reader.readElementBE!short();
                    } else {
                        composite.position.x = reader.readElementBE!ushort();
                        composite.position.y = reader.readElementBE!ushort();
                    }
                } else {
                    if (composite.flags & ARGS_ARE_XY_VALUES) {
                        composite.position.x = reader.readElementBE!byte();
                        composite.position.y = reader.readElementBE!byte();
                    } else {
                        composite.position.x = reader.readElementBE!ubyte();
                        composite.position.y = reader.readElementBE!ubyte();
                    }
                }

                if (composite.flags & WE_HAVE_A_SCALE) {
                    float scale = cast(float)reader.readElementBE!fixed2_14();
                    composite.scale = mat2.scale(scale, scale);
                } else if (composite.flags & WE_HAVE_AN_X_AND_Y_SCALE) {
                    float scaleX = cast(float)reader.readElementBE!fixed2_14();
                    float scaleY = cast(float)reader.readElementBE!fixed2_14();
                    composite.scale = mat2.scale(scaleX, scaleY);
                } else if (composite.flags & WE_HAVE_A_TWO_BY_TWO) {
                    composite.scale.matrix[0][0] = cast(float)reader.readElementBE!fixed2_14();
                    composite.scale.matrix[0][1] = cast(float)reader.readElementBE!fixed2_14();
                    composite.scale.matrix[1][0] = cast(float)reader.readElementBE!fixed2_14();
                    composite.scale.matrix[1][1] = cast(float)reader.readElementBE!fixed2_14();
                } else {
                    composite.scale = mat2.scale(1, 1);
                }

                composites = composites.nu_resize(composites.length+1);
                composites[$-1] = composite;
            } while(composite.flags & MORE_COMPONENTS);
        }
    }

    /**
        Draws the glyf with the given callbacks.
        
        Params:
            outline     = The outline drawing callbacks to call.
            position    = The start position of the outline.
            scale       = The scale to apply to the outline.
            userdata    = Userdata to pass to drawing functions.
    */
    void drawWith(GlyphDrawCallbacks outline, vec2 position, mat2 scale, void* userdata) {

        if (isComposite) {
            foreach(ref composite; composites) {
                outline.moveTo(position.x, position.y, userdata);
                glyf.findGlyf(composite.glyphIndex).drawWith(outline, composite.position, composite.scale * scale, userdata);
            }
            return;
        }

        // NOTE: Temporary stores needed to calculate outlines from the
        //       compressed form, start and first differ due to how outlines
        //       can start and end with off-curve points; in which case you need
        //       to use the point after the first to calculate the ghost control point. 
        GlyfPoint start;
        GlyfPoint first;
        GlyfPoint last;
        GlyfPoint curr = GlyfPoint(position * scale, false);
        foreach(ref GlyfContour contour; contours) {
            
            // Skip empty contours.
            if (contour.points.length == 0)
                continue;
            
            foreach(i; 0..contour.points.length) {
                last = curr;
                curr = contour.points[i];
                
                vec2 currScaled = curr.point * scale;

                // Calculate absolute point
                curr.point.x = last.point.x + currScaled.x;
                curr.point.y = last.point.y - currScaled.y;
                
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
    A glyph composite definition
*/
struct GlyfComposite {
    ushort flags;
    ushort glyphIndex;
    vec2 position;
    mat2 scale;
}

/**
    A glyph contour
*/
struct GlyfContour {
@nogc:
    GlyfPoint[] points;

    void free() {
        nu_freea(points);
    }

    /**
        Deserializes the Glyf table
    */
    void parse(ref SimpleGlyfContour contour, uint start, uint length) {
        this.points = nu_malloca!GlyfPoint(length);
        foreach(i; 0..length) {
            this.points[i] = GlyfPoint(
                point: contour.contours[start+i],
                onCurve: (contour.flags[start+i] & ON_CURVE_POINT)
            );
        }
    }
}

private
enum ushort 
    ARG_1_AND_2_ARE_WORDS       = 0x0001,
    ARGS_ARE_XY_VALUES          = 0x0002,
    ROUND_XY_TO_GRID            = 0x0004,
    WE_HAVE_A_SCALE             = 0x0008,
    MORE_COMPONENTS             = 0x0020,
    WE_HAVE_AN_X_AND_Y_SCALE    = 0x0040,
    WE_HAVE_A_TWO_BY_TWO        = 0x0080,
    WE_HAVE_INSTRUCTIONS        = 0x0100,
    USE_MY_METRICS              = 0x0200,
    OVERLAP_COMPOUND            = 0x0400,
    SCALED_COMPONENT_OFFSET     = 0x0800,
    UNSCALED_COMPONENT_OFFSET   = 0x1000;

/**
    A point in a glyph contour
*/
struct GlyfPoint {
    vec2 point = vec2(0, 0);
    bool onCurve = false;
}

/// Only used internally to construct GlyfContour
struct SimpleGlyfContour {
@nogc:
    ushort[] endPtsOfContours;
    ubyte[] instructions;
    ubyte[] flags;
    vec2[] contours;

    void free() {
        nu_freea(endPtsOfContours);
        nu_freea(instructions);
        nu_freea(flags);
        nu_freea(contours);
    }

    /**
        Deserializes the Glyf table
    */
    void deserialize(FontReader reader, ushort contourCount) {
        
        // endPtsOfContours
        this.endPtsOfContours = nu_malloca!ushort(contourCount);
        reader.readElementsBE!ushort(endPtsOfContours);

        // instructions
        ushort instructionLength = reader.readElementBE!ushort;
        if (instructionLength > 0) {
            this.instructions = nu_malloca!ubyte(instructionLength);
            reader.read(instructions);
        }

        ushort pointCount = cast(ushort)(endPtsOfContours[$-1]+1);
        if (pointCount > 0) {
            this.flags = nu_malloca!ubyte(pointCount);
            this.contours = nu_malloca!vec2(pointCount);

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
    void deserialize(FontReader reader, HeadTable head, MaxpTable maxp) {
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
