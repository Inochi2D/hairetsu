/**
    Hairetsu SFNT Font Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.font;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.tt.cmap;
import hairetsu.font.tt.types;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.font.cmap;
import hairetsu.glyph;
import hairetsu.common;

import nulib.collections;
import numem;

/**
    SFNT Font Object

    Implements shared functionality between different
    SFNT typed fonts.
*/
abstract
class SFNTFont : HaFont {
@nogc:
private:
    map!(ushort, nstring) names;
    vector!(string) tableNames;
    SFNTMaxpTable maxp;
    TTHheaTable hhea;
    TTVheaTable vhea;
    TTCharMap charmap;
    HaFontMetrics fmetrics_;
    HaGlyphStoreType glyphTypes_;
    SFNTFontEntry entry_;

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
    //      NAME TABLE
    //

    void parseNameTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("name"))) {
            reader.seek(table.offset);

            ushort format = reader.readElementBE!ushort();
            if (format > 1)
                return;

            ushort nameRecordCount = reader.readElementBE!ushort();
            size_t stringOffset = table.offset+reader.readElementBE!ushort();

            // Go through records
            foreach(ref record; reader.readRecords!SFNTNameRecord(nameRecordCount)) {

                // Non-unicode IDs not supported.
                if (!isUnicodeName(record))
                    continue;

                // Read UTF16-BE encoded name string.
                reader.seek(stringOffset+record.offset);
                names[record.nameId] = reader.readUTF16BE(record.length);
            }
        }
    }

    bool isUnicodeName(SFNTNameRecord record) {
        return 
            (record.platformId == 0) ||
            (record.platformId == 3 && (record.encodingId == 1 || record.encodingId == 10));
    }

    //
    //     HEAD TABLE
    //
    void parseHeadTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("head"))) {
            reader.seek(table.offset);
            head = reader.readRecord!TTHeadTable();
        }
    }


    //
    //     METRICS TABLES
    //
    void parseMetricsTables(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("hhea"))) {
            reader.seek(table.offset);
            hhea = reader.readRecord!TTHheaTable();

            fmetrics_.ascender.x = hhea.ascender;
            fmetrics_.descender.x = hhea.descender;
            fmetrics_.lineGap.x = hhea.lineGap;
            fmetrics_.maxExtent.x = hhea.xMaxExtent;
            fmetrics_.maxAdvance.x = hhea.advanceWidthMax;
        }

        if (auto table = entry.findTable(ISO15924!("vhea"))) {
            reader.seek(table.offset);
            vhea = reader.readRecord!TTVheaTable();

            fmetrics_.ascender.y = vhea.ascender;
            fmetrics_.descender.y = vhea.descender;
            fmetrics_.lineGap.y = vhea.lineGap;
            fmetrics_.maxExtent.y = vhea.yMaxExtent;
            fmetrics_.maxAdvance.y = vhea.advanceHeightMax;
        }
    }


    //
    //      MAXP TABLE
    //
    void parseMaxpTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("maxp"))) {
            reader.seek(table.offset);
            maxp = reader.readRecord!SFNTMaxpTable();
        }
    }


    //
    //      CMAP TABLE
    //

    void parseCmapTable(SFNTReader reader) {
        this.charmap = nogc_new!TTCharMap();

        if (auto table = entry.findTable(ISO15924!("cmap"))) {
            reader.seek(table.offset);
            charmap.parseCmapTable(reader);
        }
    }

    //
    //      OS/2 TABLE
    //

    void parseOS2Table(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("OS/2"))) {
            reader.seek(table.offset);
            os2 = reader.readRecord!SFNTOS2Table;
            
            fmetrics_.ascender.x = os2.sTypoAscender;
            fmetrics_.descender.x = os2.sTypoDescender;
            fmetrics_.lineGap.x = os2.sTypoLineGap;
        }
    }

    //
    //      Outlines
    //
    void detectOutlines() {
        if (auto table = entry.findTable(ISO15924!("glyf"))) {
            glyphTypes_ |= HaGlyphStoreType.trueType;
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF "))) {
            glyphTypes_ |= HaGlyphStoreType.CFF;
        }
        
        if (auto table = entry.findTable(ISO15924!("CFF2"))) {
            glyphTypes_ |= HaGlyphStoreType.CFF2;
        }
        
        if (auto table = entry.findTable(ISO15924!("SVG"))) {
            glyphTypes_ |= HaGlyphStoreType.SVG;
        }
        
        if (auto table = entry.findTable(ISO15924!("sbix"))) {
            glyphTypes_ |= HaGlyphStoreType.bitmap;
        }
        
        if (auto table = entry.findTable(ISO15924!("EBDT"))) {
            glyphTypes_ |= HaGlyphStoreType.bitmap;
        }
        
        if (auto table = entry.findTable(ISO15924!("CBDT"))) {
            glyphTypes_ |= HaGlyphStoreType.bitmap;
        }
    }
    

    //
    //      TrueType Outlines
    //

    ptrdiff_t getGlyfOffset(GlyphIndex index, ref bool hasOutlines) {
        if (auto table = entry.findTable(ISO15924!("loca"))) {
            reader.seek(table.offset);

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

protected:

    /**
        The shared head table
    */
    TTHeadTable head;

    /**
        The OS/2 table.

        May not exist in TrueType files.
    */
    SFNTOS2Table os2;
    
    /**
        The reader instance
    */
    SFNTReader reader;
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFontLoad(HaFontReader reader) {
        this.reader = cast(SFNTReader)reader;
        this.indexTables();

        this.parseHeadTable(this.reader);
        this.parseNameTable(this.reader);
        this.parseMaxpTable(this.reader);
        this.parseCmapTable(this.reader);

        // OS/2 metrics are preferred.
        this.parseMetricsTables(this.reader);
        this.parseOS2Table(this.reader);

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
        return nameIdx in names ? names[nameIdx][] : null;
    }

public:

    /**
        Attempts to read the Glyf table if any exists.
    */
    final
    TTGlyfTable getGlyfTable(GlyphIndex index) {
        bool hasOutlines;
        ptrdiff_t gHeaderOffset = this.getGlyfOffset(index, hasOutlines);

        if (gHeaderOffset >= 0) {
            if (auto table = entry.findTable(ISO15924!("glyf"))) {
                reader.seek(table.offset+gHeaderOffset);

                if (hasOutlines)
                    return reader.readRecord!TTGlyfTable();

                // No outlines, clear contours.
                auto header = reader.readRecord!TTGlyfTableHeader();
                header.numberOfCountours = 0;
                return TTGlyfTable(header: header);
            }
        }

        return TTGlyfTable.init;
    }

    /**
        Attempts to read the Glyf table header if any exists.
    */
    final
    TTGlyfTableHeader getGlyfHeader(GlyphIndex index) {
        bool hasOutlines;
        ptrdiff_t gHeaderOffset = getGlyfOffset(index, hasOutlines);

        if (gHeaderOffset >= 0) {
            if (auto table = entry.findTable(ISO15924!("glyf"))) {
                reader.seek(table.offset+gHeaderOffset);
                return reader.readRecord!TTGlyfTableHeader();
            }
        }

        return TTGlyfTableHeader.init;
    }

    /**
        Whether the given glyph index has a TrueType
        outline.
    */
    final
    bool hasGlyfOutline(GlyphIndex index) {
        bool hasOutlines;
        return this.getGlyfOffset(index, hasOutlines) >= 0 && hasOutlines;
    }

    /*
        Destructor
    */
    ~this() {
        if (charmap)
            nogc_delete(charmap);
    }

    /**
        Constructs a new font face from a stream.
    */
    this(SFNTFontEntry entry, HaFontReader reader) {
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
    @property HaGlyphStoreType glyphTypes() { return glyphTypes_; }

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
    @property HaCharMap charMap() { return charmap; }

    /**
        Font-wide shared metrics.
    */
    override
    @property HaFontMetrics fontMetrics() { return fmetrics_; }

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
    HaGlyphMetrics getMetricsFor(GlyphIndex glyph) {
        HaGlyphMetrics metrics;
        TTMetricRecord metricRecord;

        // Avoid indexing out of range.
        if (glyph >= glyphCount)
            return metrics;

        if (auto table = entry.findTable(ISO15924!("hmtx"))) {
            reader.seek(table.offset);

            // Handle the optimization step.
            if (glyph > hhea.numberOfHMetrics) {
                reader.skip((hhea.numberOfHMetrics-1)*TTMetricRecord.sizeof);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.advance.x = metricRecord.advance;

                reader.skip((glyph-hhea.numberOfHMetrics));
                metrics.bearing.x = reader.readElementBE!ushort();
            } else {

                // Skip to our glyph's entry.
                reader.skip(TTMetricRecord.sizeof*glyph);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.bearing.x = metricRecord.bearing;
                metrics.advance.x = metricRecord.advance;
            }
        }

        if (auto table = entry.findTable(ISO15924!("vmtx"))) {
            reader.seek(table.offset);

            // Handle the optimization step.
            if (glyph > vhea.numberOfVMetrics) {
                reader.skip((vhea.numberOfVMetrics-1)*TTMetricRecord.sizeof);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.advance.y = metricRecord.advance;

                reader.skip((glyph-vhea.numberOfVMetrics));
                metrics.bearing.y = reader.readElementBE!ushort();
            } else {

                // Skip to our glyph's entry.
                reader.skip(TTMetricRecord.sizeof*glyph);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.bearing.y = metricRecord.bearing;
                metrics.advance.y = metricRecord.advance;
            }
        }

        // TrueType Outlines store size in glyf header.
        if (glyphTypes & HaGlyphStoreType.trueType) {
            auto header = this.getGlyfHeader(glyph);

            metrics.bounds.xMin = cast(float)header.xMin;
            metrics.bounds.xMax = cast(float)header.xMax;
            metrics.bounds.yMin = cast(float)header.yMin;
            metrics.bounds.yMax = cast(float)header.yMax;
        }

        return metrics;
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
    HaFontFace onCreateFace(HaFontReader reader) {
        return null;
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
    override @property string type() { return "Unknown"; }
}
