module hairetsu.font.sfnt.file;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.file;
import hairetsu.font.font;
import hairetsu.common;

import nulib.collections;
import numem;

/**
    The header of a SFNT
*/
struct SFNTHeader {
    uint sfntVersion;
    ushort tableCount;
    ushort searchRange;
    ushort entrySelector;
    ushort rangeShift;
}

/**
    A table record of a SFNT
*/
struct SFNTTableRecord {
    uint tag;
    uint checksum;
    uint offset;
    uint length;
}

/**
    Font entries for a SFNT.

    For non-collection fonts there will be just a single
    entry.

    Note:
        The entry itself does not own the memory of the
        table slice, do NOT manipulate it.
*/
struct SFNTFontEntry {
@nogc:

    /**
        Index of the entry.
    */
    uint index;
    
    /**
        The type of the font
    */
    SFNTFontType type;
    
    /**
        The header of the font
    */
    SFNTHeader header;
    
    /**
        The table records of the font
    */
    SFNTTableRecord[] tables;

    ~this() {
        nogc_delete(tables);
    }

    /**
        Attempts to find the requested table within the font
        entry.

        Params:
            tag = The tag to look for
        
        Returns:
            A $(D SFNTTableRecord) pointer if successful,
            $(D null) otherwise.
    */
    SFNTTableRecord* findTable(uint tag) @trusted nothrow {
        foreach(ref SFNTTableRecord table; tables) {
            if (table.tag == tag)
                return &table;
        }
        
        return null;
    }
}

/**
    SFNT-based Font File
*/
class SFNTFontFile : FontFile {
private:
@nogc:
    vector!SFNTFontEntry fontEntries;

    SFNTFontEntry parseSFNTEntry(uint tag, uint idx, uint offset) {
        SFNTFontEntry entry;

        // Determine tag
        switch(tag) {

            // OpenType
            case ISO15924!("OTTO"):
            case 0x00010000:
                entry.type = SFNTFontType.openType;
                break;
            
            // TrueType
            case ISO15924!("true"):
                entry.type = SFNTFontType.trueType;
                break;
            
            // Type 1
            case ISO15924!("typ1"):
                entry.type = SFNTFontType.postScript;
                break;
            
            // TrueType Collections
            case ISO15924!("ttcf"):
                throw nogc_new!FontReadException("Nested collections are not supported!");

            default:
                throw nogc_new!FontReadException("Unsupported font format ID!");
        }

        // Determine font table metadata.
        entry.index = idx;

        // Parse rest of header.
        reader.seek(offset);

        entry.header = reader.readRecordBE!SFNTHeader;
        entry.tables = ha_allocarr!SFNTTableRecord(entry.header.tableCount);
        foreach(ref table; entry.tables)
            table = reader.readRecordBE!SFNTTableRecord;
        
        return entry;
    }

    void parseHeader(uint idx = 0, uint offset = 0) {
        reader.seek(offset);

        // Get tag, then realign.
        uint fileTag = reader.readElementBE!uint();
        switch(fileTag) {
            
            // TrueType Collections
            case ISO15924!("ttcf"):
                reader.skip(4);

                // Get subfont count.
                uint numFonts = reader.readElementBE!uint();
                vector!uint offsets = vector!uint(numFonts);
                offsets.resize(numFonts);
                reader.readElementsBE(offsets[]);

                // Read the subfonts.
                foreach(i, uint foffset; offsets) {
                    this.parseHeader(cast(uint)i, foffset);
                }
                break;
            
            // Skip DSIG
            case ISO15924!("DSIG"):
                break;
            
            default:
                this.fontEntries ~= this.parseSFNTEntry(fileTag, idx, offset);
                break;
        }
    }

protected:

    /**
        Implemented by the font file reader to index the faces.
    */
    override
    void onIndexFont(ref weak_vector!Font fonts) {
        this.parseHeader();
        foreach(ref SFNTFontEntry entry; this.fontEntries) {
            switch(entry.type) {
                case SFNTFontType.openType:
                    fonts ~= nogc_new!SFNTFont(entry, reader, SFNTFontType.openType);
                    break;

                case SFNTFontType.trueType:
                    fonts ~= nogc_new!SFNTFont(entry, reader, SFNTFontType.trueType);
                    break;

                case SFNTFontType.postScript:
                    fonts ~= nogc_new!SFNTFont(entry, reader, SFNTFontType.postScript);
                    break;

                default:
                    fonts ~= nogc_new!SFNTFont(entry, reader, SFNTFontType.unknown);
                    break;
            }
        }
    }

public:

    /**
        The type of the font file, essentially its container.
    */
    override @property string type() { return "SFNT"; }

    /**
        Constructs a font file from a stream.

        Params:
            reader =    The font reader to read the file from.
            name =      (optional) name of the font, usually its file path
    */
    this(FontReader reader, string name = "<memory stream>") {
        super(reader, name);
    }
}
