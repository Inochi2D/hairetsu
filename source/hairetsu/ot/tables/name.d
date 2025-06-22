/**
    OpenType Name Table.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/head
*/
module hairetsu.ot.tables.name;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;
import nulib.collections.vector;
import nulib.collections.map;
import nulib.string;

/**
    Name Table
*/
struct NameTable {
private:
@nogc:
    
    void deserializeV0(FontReader reader, size_t start) {
        ushort count = reader.readElementBE!ushort;
        uint storageOffset = reader.readElementBE!ushort;

        this.records = ha_allocarr!NameRecord(count);
        foreach(i; 0..count) {
            this.records[i].header = reader.readRecordBE!NameRecordHeader;

            // Skip parsing non-unicode names.
            if (!this.records[i].header.isUnicodeName()) {
                reader.skip(4); // Skip string info
                continue;
            }

            this.records[i].deserialize(reader, start+storageOffset);
        }
    }

    void deserializeV1(FontReader reader, size_t start) {
        ushort count = reader.readElementBE!ushort;
        uint storageOffset = reader.readElementBE!ushort;

        this.records = ha_allocarr!NameRecord(count);
        foreach(i; 0..count) {
            this.records[i].header = reader.readRecordBE!NameRecordHeader;

            // Skip parsing non-unicode names.
            if (!this.records[i].header.isUnicodeName()) {
                reader.skip(4); // Skip string info
                continue;
            }

            this.records[i].deserialize(reader, start+storageOffset);
        }

        ushort tagCount = reader.readElementBE!ushort;
        this.languageTags = ha_allocarr!LanguageTagRecord(tagCount);
        foreach(i; 0..tagCount) {
            this.languageTags[i].deserialize(reader, start+storageOffset);
        }
    }

public:
    NameRecord[] records;
    LanguageTagRecord[] languageTags;

    void free() {
        this.records = records.nu_resize(0);
        this.languageTags = languageTags.nu_resize(0);
    }

    void deserialize(FontReader reader) {
        size_t start = reader.tell();
        ushort version_ = reader.readElementBE!ushort;

        switch(version_) {

            case 0:
                deserializeV0(reader, start);
                break;

            case 1:
                deserializeV1(reader, start);
                break;

            default:
                assert(0, "Invalid version!");
        }
    }

    /**
        Finds a name from the name table.
    */
    string findName(ushort nameIdx) {
        foreach(ref NameRecord item; records) {
            if (item.header.nameId == nameIdx)
                return item.name[];
        }

        return null;
    }
}

/**
    Header for a name record.
*/
struct NameRecordHeader {
@nogc:
    ushort platformId;
    ushort encodingId;
    ushort languageId;
    ushort nameId;

    /**
        Whether the name record is a unicode name.
    */
    bool isUnicodeName() {
        return 
            (platformId == 0) ||
            (platformId == 3 && (encodingId == 1 || encodingId == 10));
    }
}

/**
    A name record
*/
struct NameRecord {
@nogc:
    NameRecordHeader header;
    nstring name;
    
    /**
        Gets the language ID of the record.
    */
    ushort languageId() {
        return header.languageId;
    }

    void deserialize(FontReader reader, size_t start) {
        ushort strlen = reader.readElementBE!ushort;
        ushort tblOffset = reader.readElementBE!ushort;
        size_t dataEnd = reader.tell();

        reader.seek(start+tblOffset);
        name = reader.readUTF16BE(strlen);

        reader.seek(dataEnd);
    }
}

/**
    A language tag record
*/
struct LanguageTagRecord {
@nogc:
    nstring name;

    void deserialize(FontReader reader, size_t start) {
        ushort strlen = reader.readElementBE!ushort;
        ushort tblOffset = reader.readElementBE!ushort;
        size_t dataEnd = reader.tell();

        reader.seek(start+tblOffset);
        name = reader.readUTF16BE(strlen);

        reader.seek(dataEnd);
    }
}