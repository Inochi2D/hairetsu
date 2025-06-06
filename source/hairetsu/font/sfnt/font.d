/**
    Hairetsu SFNT Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.font;
import hairetsu.font.tables;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.tt.cmap;
import hairetsu.font.tt.types;
import hairetsu.font.types;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.font.cmap;
import hairetsu.glyph;
import hairetsu.common;

import nulib.collections;
import numem;

// Tables
import hairetsu.font.tables.name;
import hairetsu.font.tables.maxp;
import hairetsu.font.tables.head;
import hairetsu.font.tables.glyf;
import hairetsu.font.tables.os2;

/**
    SFNT Font Object

    Implements shared functionality between different
    SFNT typed fonts.
*/
abstract
class SFNTFont : Font {
@nogc:
private:
    /// Entry info.
    vector!(string) tableNames;
    SFNTFontEntry entry_;

    // Base Tables
    NameTable names;
    MaxpTable maxp;
    HeadTable head;
    OS2Table os2;

    // Font Info
    GlyphStoreType gtypes;
    TTCharMap charmap;

    // Glyphs
    GlyfTable glyf;

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
        this.charmap = nogc_new!TTCharMap();

        if (auto table = entry.findTable(ISO15924!("cmap"))) {
            reader.seek(table.offset);
            charmap.parseCmapTable(reader);
        }
    }

    //
    //     METRICS TABLES
    //
    void parseMetricsTables(SFNTReader reader) {
        import hairetsu.font.tables.hhea : HheaTable;
        import hairetsu.font.tables.hmtx : HmtxTable;
        import hairetsu.font.tables.vhea : VheaTable;
        import hairetsu.font.tables.vmtx : VmtxTable;
        
        // Horizontal Metrics
        HheaTable hhea;
        HmtxTable hmtx;
        if (this.parseTable!HheaTable(reader, ISO15924!("hhea"), hhea)) {
            fmetrics.ascender.x = hhea.ascender;
            fmetrics.descender.x = hhea.descender;
            fmetrics.lineGap.x = hhea.lineGap;
            fmetrics.maxExtent.x = hhea.xMaxExtent;
            fmetrics.maxAdvance.x = hhea.advanceWidthMax;

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
            this.gtypes |= GlyphStoreType.trueType;
            this.parseGlyfTable(reader);
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF "))) {
            this.gtypes |= GlyphStoreType.CFF;
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF2"))) {
            this.gtypes |= GlyphStoreType.CFF2;
        }
        
        if (auto table = entry.findTable(ISO15924!("SVG"))) {
            this.gtypes |= GlyphStoreType.SVG;
        }
        
        if (auto table = entry.findTable(ISO15924!("sbix"))) {
            this.gtypes |= GlyphStoreType.bitmap;
        }
        
        if (auto table = entry.findTable(ISO15924!("EBDT"))) {
            this.gtypes |= GlyphStoreType.bitmap;
        }
        
        if (auto table = entry.findTable(ISO15924!("CBDT"))) {
            this.gtypes |= GlyphStoreType.bitmap;
        }
    }
    

    //
    //      TrueType Outlines
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

            // Free loca table after we're done.
            loca.free();
        }
    }

protected:

    /// Helper for parsing tables.
    bool parseTable(T)(SFNTReader reader, Tag tag, ref T target) {
        if (auto table = entry.findTable(tag)) {
            reader.seek(table.offset);
            target = reader.readRecord!T;
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
    this(SFNTFontEntry entry, FontReader reader) {
        this.entry_ = entry;

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
    @property string type() { return "SFNT derived"; }

    /**
        The types of outline found in the SFNT file.

        This is represented as a bit flag.
    */
    override
    @property GlyphStoreType glyphTypes() { return gtypes; }

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
    @property HaRect!int boundingBox() {
        return HaRect!int(head.xMin, head.xMax, head.yMin, head.yMax);
    }

    /**
        Gets the vertical metrics for the given glyph.
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
        if (glyf.hasOutline(glyph))
            gtype |= GlyphType.outline;

        return gtype;
    }

    //
    //      Glyf
    //

    /**
        Gets whether the given index has a glyf outline.
    */
    final
    bool hasGlyfOutline(GlyphIndex index) {
        return glyf.hasOutline(index);
    }

    /**
        Gets the glyf record for the given index.
    */
    final
    GlyfRecord getGlyfRecord(GlyphIndex index) {
        return 
            index < glyf.glyphs.length ? 
            glyf.glyphs[index] : 
            GlyfRecord.init;
    }
}

/**
    A dummy SFNT font with no faces.
*/
class SFNTUnknownFont : SFNTFont {
private:
@nogc:
protected:
    
    /**
        Implemented by the font to create a new font face.
    */
    override
    FontFace onCreateFace(FontReader reader) {
        return null;
    }

public:
    
    /**
        Constructs a new font face from a stream.
    */
    this(SFNTFontEntry entry, FontReader reader) {
        super(entry, reader);
    }

    /**
        The name of the type of font.
    */
    override @property string type() { return "Unknown"; }
}
