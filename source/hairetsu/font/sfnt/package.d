/**
    Hairetsu SFNT Font Container

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt;
import hairetsu.font.sfnt.reader;
import nulib.collections;
import numem;

import hairetsu.font : HaFont, HaFontFace, HaFontReadException;
import hairetsu.common;

/**
    SFNT-based Font File
*/
class SFNTFont : HaFont {
@nogc:
protected:

    /**
        Implemented by the font file reader to index the faces.
    */
    override
    void onIndexFont(ref weak_vector!HaFontFace faces) {
        import nulib.c.stdio : printf;

        foreach(ref SFNTFontEntry entry; (cast(SFNTReader)reader).fontEntries) {
            final switch(entry.type) {
                case SNFTFontType.openType:

                    import hairetsu.font.ot : OTFontFace;
                    faces ~= nogc_new!OTFontFace(entry, reader);
                    break;

                case SNFTFontType.trueType:

                    import hairetsu.font.tt : TTFontFace;
                    faces ~= nogc_new!TTFontFace(entry, reader);
                    break;

                // Not supported for now.
                case SNFTFontType.type1:
                    break;
            }
        }
    }

public:

    /**
        Constructs a font file from a stream.

        Params:
            reader =    The font reader to read the file from.
            name =      (optional) name of the font, usually its file path
    */
    this(SFNTReader reader, string name = "<memory stream>") {
        super(reader, name);
    }
}

/**
    SFNT Font Face base class

    Implements shared functionality between different
    SFNT typed fonts.
*/
abstract
class SFNTFontFace : HaFontFace {
@nogc:
private:
    SFNTFontEntry entry;
    map!(ushort, nstring) names;

    bool isUnicodeName(SFNTNameRecord record) {
        return 
            (record.platformId == 0) ||
            (record.platformId == 3 && record.encodingId == 10);
    }

    void parseNameTable(SFNTReader reader) {
        if (auto nameTable = entry.findTable(ISO15924!("name"))) {
            size_t tableOffset = entry.offset+nameTable.offset;
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

protected:
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(HaFontReader reader) {
        this.parseNameTable(cast(SFNTReader)reader);
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
        Amount of glyphs within font face.
    */
    override
    @property size_t glyphCount() { return 0; }

    /**
        Units per EM.
    */
    override
    @property uint upem() { return 0; }

    /**
        Fills all of the unicode codepoints that the face supports,
        and writes them to the given set.

        Params:
            cSet = The set to fill.

        Returns:
            The amount of codepoints that were added to the set.
    */
    override
    uint fillCodepoints(ref set!codepoint cSet) { return 0; }
}
