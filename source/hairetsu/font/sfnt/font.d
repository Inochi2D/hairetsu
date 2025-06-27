/**
    Hairetsu SFNT Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.font;
import hairetsu.font.sfnt;
import hairetsu.font;
import hairetsu.common;

import nulib.collections;
import numem;

// Tables
import hairetsu.ot.tables.name;
import hairetsu.ot.tables.maxp;
import hairetsu.ot.tables.head;
import hairetsu.ot.tables.glyf;
import hairetsu.ot.tables.svg;
import hairetsu.ot.tables.os2;

/**
    The type of the SFNT
*/
enum SFNTFontType {

    /**
        A CFF1/2 OpenType Font
    */
    openType,
    
    /**
        A TrueType font
    */
    trueType,
    
    /**
        A PostScript font
    */
    postScript,

    /**
        Unknown font file which uses the SFNT
        format.
    */
    unknown
}

/**
    SFNT Font Object

    Implements shared functionality between different
    SFNT typed fonts.
*/
class SFNTFont : Font {
@nogc:
private:
    SFNTFontType fontType;

    /// Entry info.
    vector!(string) tableNames;
    SFNTFontEntry entry_;

    // Base Tables
    NameTable names;
    MaxpTable maxp;
    HeadTable head;
    OS2Table os2;

    // Font Info
    GlyphType gtypes;
    SFNTCharMap charmap;

    // Glyphs
    GlyfTable glyf;
    SVGTable svg;

    // Metrics
    vector!GlyphMetrics gmetrics;
    FontMetrics fmetrics;

    //
    //      INDEXING
    //
    void indexTables() {
        foreach(SFNTTableRecord table; entry.tables) {
            import nulib.memory.endian : nu_etoh, Endianess;

            char[4] tagCode = nu_etoh(reinterpret_cast!(char[4])(table.tag), Endianess.bigEndian);
            tableNames ~= (cast(string)tagCode).nu_dup();
        }
    }

    //
    //      CORE TABLES
    //

    void parseBaseTables(SFNTReader reader) {
        
        // These should always be there.
        this.parseTable!MaxpTable(reader, ISO15924!("maxp"), this.maxp);
        this.parseTable!HeadTable(reader, ISO15924!("head"), this.head);
        this.parseTable!NameTable(reader, ISO15924!("name"), this.names);

        // Charmap
        this.parseCmapTable(this.reader);
        
        // Metrics
        this.parseMetricsTables(this.reader);
    }

    void parseCmapTable(SFNTReader reader) {
        this.charmap = nogc_new!SFNTCharMap();

        if (auto table = entry.findTable(ISO15924!("cmap"))) {
            reader.seek(table.offset);
            charmap.parseCmapTable(reader);
        }
    }

    //
    //     METRICS TABLES
    //
    void parseMetricsTables(SFNTReader reader) {
        import hairetsu.ot.tables.hhea : HheaTable;
        import hairetsu.ot.tables.hmtx : HmtxTable;
        import hairetsu.ot.tables.vhea : VheaTable;
        import hairetsu.ot.tables.vmtx : VmtxTable;
        
        // Horizontal Metrics
        HheaTable hhea;
        HmtxTable hmtx;
        if (this.parseTable!HheaTable(reader, ISO15924!("hhea"), hhea)) {
            fmetrics.ascender.x = hhea.ascender;
            fmetrics.descender.x = hhea.descender;
            fmetrics.lineGap.x = hhea.lineGap;
            fmetrics.maxExtent.x = hhea.xMaxExtent;
            fmetrics.maxAdvance.x = hhea.advanceWidthMax;
            fmetrics.minBearingStart.x = hhea.minLeftSideBearing;
            fmetrics.minBearingEnd.x = hhea.minRightSideBearing;

            if (auto subtable = entry.findTable(ISO15924!("hmtx"))) {
                reader.seek(subtable.offset);
                hmtx.deserialize(reader, hhea, glyphCount);
            }
        }

        // Vertical Metrics
        VheaTable vhea;
        VmtxTable vmtx;
        if (this.parseTable!VheaTable(reader, ISO15924!("vhea"), vhea)) {
            fmetrics.ascender.y = vhea.ascender;
            fmetrics.descender.y = vhea.descender;
            fmetrics.lineGap.y = vhea.lineGap;
            fmetrics.maxExtent.y = vhea.yMaxExtent;
            fmetrics.maxAdvance.y = vhea.advanceHeightMax;
            fmetrics.minBearingStart.y = vhea.minTopSideBearing;
            fmetrics.minBearingEnd.y = vhea.minBottomSideBearing;

            if (auto subtable = entry.findTable(ISO15924!("vmtx"))) {
                reader.seek(subtable.offset);
                vmtx.deserialize(reader, vhea, glyphCount);
            }
        }

        // Individual glyph metrics.
        gmetrics.resize(glyphCount);
        foreach(i; 0..glyphCount) {
            MtxRecord ghmtx = i < hmtx.records.length ? hmtx.records[i] : MtxRecord.init;
            MtxRecord gvmtx = i < vmtx.records.length ? vmtx.records[i] : MtxRecord.init;

            this.gmetrics[i] = GlyphMetrics(
                advance: vec2(cast(float)ghmtx.advance, cast(float)gvmtx.advance),
                bearing: vec2(cast(float)ghmtx.bearing, cast(float)gvmtx.bearing),
            );
        }

        // Free temporary tables.
        hmtx.free();
        vmtx.free();

        // Parse OS/2 Table.
        // This table should be preferred over the hhea/vhea tables.
        // So we overwrite some stuff if we find it.
        if (this.parseTable!OS2Table(reader, ISO15924!("OS/2"), os2)) {
            fmetrics.ascender.x = os2.sTypoAscender;
            fmetrics.descender.x = os2.sTypoDescender;
            fmetrics.lineGap.x = os2.sTypoLineGap;
        }
    }

    //
    //      Outlines
    //
    void detectOutlines() {
        if (auto table = entry.findTable(ISO15924!("glyf"))) {
            this.gtypes |= GlyphType.trueType;
            this.parseGlyfTable(reader);
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF "))) {
            this.gtypes |= GlyphType.cff;
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF2"))) {
            this.gtypes |= GlyphType.cff2;
        }
        
        if (auto table = entry.findTable(ISO15924!("SVG"))) {
            this.gtypes |= GlyphType.svg;
            this.parseSVGTable(reader);
        }
        
        if (auto table = entry.findTable(ISO15924!("sbix"))) {
            this.gtypes |= GlyphType.sbix;
        }
        
        if (auto table = entry.findTable(ISO15924!("EBDT"))) {
            this.gtypes |= GlyphType.ebdt;
        }
        
        if (auto table = entry.findTable(ISO15924!("CBDT"))) {
            this.gtypes |= GlyphType.cbdt;
        }
    }
    

    //
    //      Glyphs
    //

    void parseGlyfTable(SFNTReader reader) {
        LocaTable loca;
        if (auto locaTable = entry.findTable(ISO15924!("loca"))) {
            reader.seek(locaTable.offset);
            loca.deserialize(reader, head, maxp);

            if (auto table = entry.findTable(ISO15924!("glyf"))) {
                reader.seek(table.offset);
                glyf.deserialize(reader, loca);
            
                // Load glyph bounds.
                foreach(i; 0..min(glyf.glyphs.length, gmetrics.length)) {            
                    gmetrics[i].bounds = glyf.glyphs[i].bounds;
                }
            }

            // Finalize.
            loca.free();
        }
    }

    void parseSVGTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("SVG "))) {
            this.svg = reader.readRecordBE!SVGTable();
        }
    }

protected:

    /// Helper for parsing tables.
    bool parseTable(T)(FontReader reader, Tag tag, ref T target) {
        if (auto table = entry.findTable(tag)) {
            reader.seek(table.offset);
            target = reader.readRecordBE!T;
            return true;
        }
        return false;
    }
    
    /**
        The reader instance
    */
    SFNTReader reader;
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFontLoad(FontReader reader) {
        this.reader = cast(SFNTReader)reader;
        this.indexTables();

        // Parse base tables.
        this.parseBaseTables(this.reader);

        // Detect what kind of outlines are present.
        this.detectOutlines();
    }

    /**
        Implemented by the font to create a new font face.
    */
    override
    FontFace onCreateFace(FontReader reader) {
        return nogc_new!SFNTFontFace(this, reader);
    }

    /**
        Gets a name with the given index from the name table.

        Params:
            nameIdx = The index of the name
    
        Returns:
            The name or $(D null) if no name with the given ID
            was found.
    */
    final
    string getName(ushort nameIdx) {
        return names.findName(nameIdx);
    }

    //
    //      Glyf
    //

    /**
        Gets whether the given index has a glyf outline.

        Params:
            index = The glyph to query.
        
        Returns:
            $(D true) if the glyph has a glyf outline,
            $(D false) otherwise.
    */
    final
    bool hasGlyfOutline(GlyphIndex index) {
        return glyf.hasGlyph(index);
    }

    /**
        Gets the glyf record for the given index.

        Params:
            glyphId = The glyph to query.
        
        Returns:
            A glyf record reference or $(D null).
    */
    final
    GlyfRecord* getGlyfRecord(GlyphIndex glyphId) {
        return glyf.findGlyf(glyphId);
    }

    //
    //      SVG
    //

    /**
        Gets whether the given index has an SVG document.

        Params:
            index = The glyph to query.
        
        Returns:
            $(D true) if the glyph has an SVG document,
            $(D false) otherwise.
    */
    final
    bool hasSVG(GlyphIndex index) {
        return svg.hasGlyph(index);
    }

    /**
        Gets the SVG document for the given glyph index.

        Params:
            index = The glyph to query.
        
        Returns:
            A UTF8 encoded SVG document, or $(D null).
    */
    final
    string getSVG(GlyphIndex index) {
        return svg.getDocument(index);
    }

public:

    /*
        Destructor
    */
    ~this() {
        if (charmap)
            nogc_delete(charmap);
        
        // Free tables
        glyf.free();
        names.free();
        gmetrics.clear();
    }

    /**
        Constructs a new font face from a stream.
    */
    this(SFNTFontEntry entry, FontReader reader, SFNTFontType fontType) {
        this.entry_ = entry;
        this.fontType = fontType;
        super(entry_.index, reader);
    }
    
    /**
        The font entry.
    */
    final
    @property SFNTFontEntry entry() { return entry_; }

    /**
        The full name of the font face.
    */
    override
    @property string name() { return this.getName(4); }

    /**
        The font family of the font face.
    */
    override
    @property string family() { return this.getName(1); }

    /**
        The sub font family of the font face.
    */
    override
    @property string subfamily() { return this.getName(2); }

    /**
        The name of the type of font.
    */
    override
    @property string type() {
        final switch(fontType) {
            case SFNTFontType.openType:
                return "OpenType";
            case SFNTFontType.trueType:
                return "TrueType";
            case SFNTFontType.postScript:
                return "PostScript";
            case SFNTFontType.unknown:
                return "SFNT derived"; 
        }
    }

    /**
        The types of outline found in the SFNT file.

        This is represented as a bit flag.
    */
    override
    @property GlyphType glyphTypes() { return gtypes; }

    /**
        List of features the font uses.
    */
    override
    @property string[] fontFeatures() { return cast(string[])tableNames[]; }

    /**
        Amount of glyphs within the font.
    */
    override
    @property uint glyphCount() { return maxp.numGlyphs; }

    /**
        The character map for the font.
    */
    override
    @property CharMap charMap() { return charmap; }

    /**
        Font-wide shared metrics.
    */
    override
    @property FontMetrics fontMetrics() { return fmetrics; }

    /**
        Units per EM.
    */
    override
    @property uint upem() { return head.unitsPerEm; }

    /**
        The lowest recommended pixels-per-EM for readability.
    */
    override
    @property uint lowestPPEM() { return head.lowestRecPPEM; }

    /**
        The bounding box of the font.
    */
    override
    @property recti boundingBox() {
        return recti(head.xMin, head.xMax, head.yMin, head.yMax);
    }

    /**
        Gets the metrics for the given glyph.
    */
    override
    GlyphMetrics getMetricsFor(GlyphIndex glyph) {
        if (glyphCount == 0)
            return GlyphMetrics.init;

        // Avoid indexing out of range.
        if (glyph >= glyphCount)
            return gmetrics[0];
        
        return gmetrics[glyph];
    }

    /**
        Gets the given glyph.

        Params:
            glyphId = ID of the glyph to get.
            type = The type of glyph data to fetch.

        Returns:
            A glyph, or the `.notdef` glyph if no glyph
            with the given ID was found.
    */
    override
    Glyph getGlyph(GlyphIndex glyphId, GlyphType type) {
        Glyph glyph;

        glyph.font = this;
        glyph.id = glyphId;
        glyph.metrics = this.getMetricsFor(glyphId);

        // Requested nothing.
        if (type == GlyphType.none)
            return glyph;

        // Requested w/ glyph data.
        type = this.normalizeType(type, glyphId);
        switch(type) {

            // TTF Glyf Outlines.
            case GlyphType.trueType:
                if (auto record = this.getGlyfRecord(glyphId)) {
                    glyph.setData(record);
                }
                break;

            // SVG
            case GlyphType.svg:
                if (auto record = this.getSVG(glyphId)) {
                    glyph.setData(record);
                }
                break;
            
            default:
                break;
        }

        return glyph;
    }

    /**
        Gets the type of data associated with the given glyph.

        Params:
            glyph = Index of the glyph to get the state for.

        Returns:
            The types of data associated with the glyph.
    */
    override
    GlyphType getGlyphType(GlyphIndex glyph) {
        GlyphType gtype;

        // Glyf (TTF)
        if (glyf.hasGlyph(glyph))
            gtype |= GlyphType.trueType;

        // Glyf (TTF)
        if (svg.hasGlyph(glyph))
            gtype |= GlyphType.svg;

        return gtype;
    }
}