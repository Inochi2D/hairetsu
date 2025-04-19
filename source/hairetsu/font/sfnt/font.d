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
    SFNTMaxpTable maxp;
    TTHheaTable hhea;
    TTVheaTable vhea;
    TTCharMap charmap;


    //
    //      NAME TABLE
    //

    void parseNameTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("name"))) {
            size_t tableOffset = entry.offset+table.offset;
            reader.seek(tableOffset);

            ushort format = reader.readElementBE!ushort();
            if (format > 1)
                return;

            ushort nameRecordCount = reader.readElementBE!ushort();
            size_t stringOffset = tableOffset+reader.readElementBE!ushort();

            // Go through records
            foreach(ref record; reader.readRecords!SFNTNameRecord(nameRecordCount)) {

                // Non-unicode IDs not supported.
                if (isUnicodeName(record))
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
            (record.platformId == 3 && record.encodingId == 10);
    }

    //
    //     HEAD TABLE
    //
    void parseHeadTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("head"))) {
            reader.seek(entry.offset+table.offset);
            head = reader.readRecord!TTHeadTable();
        }
    }


    //
    //     METRICS TABLES
    //
    void parseMetricsTables(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("hhea"))) {
            reader.seek(entry.offset+table.offset);
            hhea = reader.readRecord!TTHheaTable();
        }

        if (auto table = entry.findTable(ISO15924!("vhea"))) {
            reader.seek(entry.offset+table.offset);
            vhea = reader.readRecord!TTVheaTable();
        }
    }


    //
    //      MAXP TABLE
    //
    void parseMaxpTable(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("maxp"))) {
            reader.seek(entry.offset+table.offset);
            maxp = reader.readRecord!SFNTMaxpTable();
        }
    }


    //
    //      CMAP TABLE
    //

    void parseCmapTable(SFNTReader reader) {
        this.charmap = nogc_new!TTCharMap();

        if (auto table = entry.findTable(ISO15924!("cmap"))) {
            reader.seek(entry.offset+table.offset);
            charmap.parseCmapTable(reader);
        }
    }

    //
    //      OS/2 TABLE
    //

    void parseOS2Table(SFNTReader reader) {
        if (auto table = entry.findTable(ISO15924!("OS/2"))) {
            reader.seek(entry.offset+table.offset);
            os2 = reader.readRecord!SFNTOS2Table;
        }
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
        The font entry.
    */
    SFNTFontEntry entry;
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFontLoad(HaFontReader reader) {
        this.reader = cast(SFNTReader)reader;

        this.parseHeadTable(this.reader);
        this.parseNameTable(this.reader);
        this.parseMaxpTable(this.reader);
        this.parseCmapTable(this.reader);
        this.parseOS2Table(this.reader);
        this.parseMetricsTables(this.reader);
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
        this.entry = entry;

        super(entry.index, reader);
    }

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
        Amount of glyphs within the font.
    */
    override
    @property size_t glyphCount() { return maxp.numGlyphs; }

    /**
        The character map for the font.
    */
    override
    @property HaCharMap charMap() { return this.charmap; }

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
            reader.seek(entry.offset+table.offset);

            // Handle the optimization step.
            if (glyph > hhea.numberOfHMetrics) {
                reader.skip((hhea.numberOfHMetrics-1)*TTMetricRecord.sizeof);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.advance.x = metricRecord.advance;

                reader.skip((glyph-hhea.numberOfHMetrics));
                metrics.bearingH.x = reader.readElementBE!ushort();
            } else {

                // Skip to our glyph's entry.
                reader.skip(TTMetricRecord.sizeof*glyph);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.bearingH.x = metricRecord.bearing;
                metrics.advance.x = metricRecord.advance;
            }
        }

        if (auto table = entry.findTable(ISO15924!("vmtx"))) {
            reader.seek(entry.offset+table.offset);

            // Handle the optimization step.
            if (glyph > vhea.numberOfVMetrics) {
                reader.skip((vhea.numberOfVMetrics-1)*TTMetricRecord.sizeof);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.advance.y = metricRecord.advance;

                reader.skip((glyph-vhea.numberOfVMetrics));
                metrics.bearingV.y = reader.readElementBE!ushort();
            } else {

                // Skip to our glyph's entry.
                reader.skip(TTMetricRecord.sizeof*glyph);
                metricRecord = reader.readRecord!TTMetricRecord();
                metrics.bearingV.y = metricRecord.bearing;
                metrics.advance.y = metricRecord.advance;
            }
        }

        return metrics;
    }
}
