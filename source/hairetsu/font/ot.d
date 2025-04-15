/**
    Hairetsu OpenType Font Implementation

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.ot;
import nulib.io.stream.memstream;
import nulib.io.stream.rw;
import nulib.io.stream;
import nulib.math.fixed;
import nulib.collections;
import nulib.text.unicode;
import nulib.string;
import numem;

import hairetsu.font : HaFontFile, HaFontFace, HaFontFileLoadException;
import hairetsu.common;

/**
    OpenType Font File
*/
class OTFontFile : HaFontFile {
@nogc:
private:
    fixed32 versionNumber;

    MemoryStream readToMemory(StreamReader reader, uint offset, uint length) {
        ubyte[] buffer;
        size_t rptr = reader.stream.tell();

        // Read data into buffer
        buffer = nu_resize(buffer, length, 1);

        reader.stream.seek(offset);
        reader.stream.read(buffer);
        reader.stream.seek(rptr);
        return nogc_new!MemoryStream(buffer);
    }

    size_t getFileLength(StreamReader reader) {
        size_t rptr = reader.stream.tell();

        reader.stream.seek(0, SeekOrigin.end);
        size_t rlen = cast(size_t)reader.stream.tell();
        reader.stream.seek(rptr);

        return rlen;
    }

protected:

    /**
        Implemented by the font file reader to index the faces.
    */
    override
    void onIndexFontFile(StreamReader reader, ref weak_vector!HaFontFace faces) {
        uint fileLength = cast(uint)getFileLength(reader);
        uint fileTag = reader.readU32BE();
        vector!uint faceOffsets;
        uint faceCount;

        // Read font (collections) from file.
        switch(fileTag) {
            case 0x00010000:
            case ISO15924!("OTTO"):
                this.versionNumber = 1;
                faces ~= nogc_new!OTFontFace(0, readToMemory(reader, 0, fileLength));
                break;
            
            case ISO15924!("ttcf"):
                versionNumber = fixed32.fromData(reader.readU32BE());
                faceCount = reader.readU32BE();
                foreach(i; 0..faceCount)
                    faceOffsets ~= reader.readU32BE();
                
                // NOTE:    This assumes that the faces are ordered in a sorted manner,
                //          if not this implementation needs to change.
                foreach(i; 0..faceCount) {
                    uint faceStart = faceOffsets[i];
                    uint faceEnd = i+1 < faceCount ? 
                        faceOffsets[i+1] : 
                        fileLength;

                    assert(faceStart < faceEnd);

                    faces ~= nogc_new!OTFontFace(i, readToMemory(reader, faceStart, faceEnd-faceStart));
                }
                break;
            
            default:
                throw nogc_new!HaFontFileLoadException("Unrecognized OpenType Font File Tag!");
        }
    }

public:

    /**
        Constructs a font file from a stream.

        Params:
            stream = The stream to read the file from.
    */
    this(Stream stream) { super(stream); }
}

/**
    OpenType Font Face
*/
class OTFontFace : HaFontFace {
@nogc:
private:
    uint index_;
    map!(uint, OTTable) tables;
    nstring[32] nameTable;

    bool isUnicodeName(OTNameRecord record) {
        return 
            (record.platformId == 0) ||
            (record.platformId == 3 && record.encodingId == 10);
    }

    void parseNameTable(StreamReader reader) {
        size_t tableOffset = tables[ISO15924!("name")].offset;
        vector!OTNameRecord records;

        reader.stream.seek(tableOffset);
        ushort format = reader.readU16BE();
        if (format > 1)
            return;

        ushort nameRecordCount = reader.readU16BE();
        size_t stringOffset = tableOffset+reader.readU16BE();

        // Index name records
        foreach(i; 0..nameRecordCount) {
            records ~= OTNameRecord(
                reader.readU16BE(),
                reader.readU16BE(),
                reader.readU16BE(),
                reader.readU16BE(),
                reader.readU16BE(),
                reader.readU16BE()
            );
        }

        // Go through records
        foreach(ref record; records) {

            // Skip keys we don't know about.
            if (record.nameId > 25)
                continue;

            // Non-unicode IDs not supported.
            if (isUnicodeName(record))
                continue;

            // Read UTF16-BE encoded name string.
            reader.stream.seek(stringOffset+record.offset);
            nameTable[record.nameId] = toUTF8(reader.readUTF16BE(record.length/2));
        }
    }

    string getName(ushort nameIdx) {
        return nameTable[nameIdx][];
    }

protected:
    
    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(StreamReader reader) {

        // Verify that the header of the face is actually OpenType.
        uint faceTag = reader.readU32BE();
        enforce(
            faceTag == 0x00010000 || 
            faceTag == ISO15924!("OTTO"), 
            nogc_new!HaFontFileLoadException("Stream is not an OpenType Font! (Invalid header tag)")
        );

        ushort tableCount = reader.readU16BE();
        reader.stream.seek(6, SeekOrigin.relative);
        foreach(i; 0..tableCount) {
            OTTable table;

            table.tag =         reader.readU32BE();
            table.checksum =    reader.readU32BE();
            table.offset =      reader.readU32BE();
            table.length =      reader.readU32BE();

            tables[table.tag] = table;
        }

        this.parseNameTable(reader);
    }

public:
    
    /**
        Constructs a new font face from a stream.
    */
    this(uint index, Stream stream) {
        super(index, stream);
    }

    /**
        The full name of the font face.
    */
    override @property string name() {
        return this.getName(4);
    }

    /**
        The font family of the font face.
    */
    override @property string family() {
        return this.getName(1);
    }

    /**
        The sub font family of the font face.
    */
    override @property string subfamily() {
        return this.getName(2);
    }

    /**
        Amount of glyphs within font face.
    */
    override @property size_t glyphCount() {
        return 0;
    }

    /**
        Units per EM.
    */
    override @property uint upem() {
        return 0;
    }

    /**
        Fills all of the unicode codepoints that the face supports,
        and writes them to the given set.

        Params:
            cSet = The set to fill.

        Returns:
            The amount of codepoints that were added to the set.
    */
    override uint fillCodepoints(ref set!codepoint cSet) {
        return 0;
    }
}

private:

/// A OpenType table
struct OTTable {
    uint tag;
    uint checksum;
    uint offset;
    uint length;
}

struct OTNameRecord {
    ushort platformId;
    ushort encodingId;
    ushort languageId;
    ushort nameId;
    ushort length;
    ushort offset;
}