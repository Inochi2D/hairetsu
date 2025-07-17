/**
    OpenType SVG Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/svg
*/
module hairetsu.ot.tables.svg;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;

/**
    SVG Table
*/
struct SVGTable {
public:
@nogc:
    SVGDocumentRecord[] svgDocuments;

    /**
        Whether the glyph at the given offset has an outline.
    */
    bool hasGlyph(uint glyphId) {
        return this.findGlyph(glyphId).isValid;
    }

    /**
        Finds a glyph within the document records.

        Params:
            glyph = The glyph to look up
        
        Returns:
            A document record instance, this instance
            may be invalid if there's no glyph with
            the requested record; check 
            $(D SVGDocumentRecord.isValid).
    */
    SVGDocumentRecord findGlyph(GlyphIndex glyph) {
        foreach(document; svgDocuments) {
            if (glyph < document.startGlyph)
                continue;

            if (glyph > document.endGlyph)
                continue;
        
            return document;
        }
        return SVGDocumentRecord.init;
    }

    /**
        Gets the SVG document for the given glyph.

        Params:
            glyph = The glyph to look up

        Returns:
            An SVG compliant document on success,
            $(D null) otherwise
    */
    string getDocument(GlyphIndex glyph) {
        SVGDocumentRecord doc = this.findGlyph(glyph);
        if (doc.startGlyph == doc.endGlyph)
            return null;

        return doc.data;
    }

    /**
        Frees the SVG Table
    */
    void free() {
        foreach(ref document; svgDocuments) {
            document.free();
        }
        nu_freea(svgDocuments);
    }
    
    /**
        Deserializes the SVG Table.

        Params:
            reader = The font data reader.
    */
    void deserialize(FontReader reader) {
        size_t start = reader.tell();

        ushort version_ = reader.readElementBE!ushort;
        uint doclistOffset = reader.readElementBE!uint;

        switch(version_) {
            case 0:
                reader.seek(start+doclistOffset);

                ushort entries = reader.readElementBE!ushort;
                this.svgDocuments = nu_malloca!SVGDocumentRecord(entries);
                foreach(i; 0..entries) {
                    ushort startGlyph = reader.readElementBE!ushort();
                    ushort endGlyph = reader.readElementBE!ushort();
                    ushort docOffset = reader.readElementBE!ushort();
                    ushort docLength = reader.readElementBE!ushort();

                    this.svgDocuments[i].startGlyph = startGlyph;
                    this.svgDocuments[i].endGlyph = endGlyph;
                    this.svgDocuments[i].data = nu_malloca!(immutable(char))(docLength);
                    
                    size_t next = reader.tell();

                    // Read the actual document text.
                    reader.seek(start+doclistOffset+docOffset);
                    reader.read(cast(ubyte[])this.svgDocuments[i].data);
                    reader.seek(next);
                }
                return;

            default:
                return;
        }
    }
}

/**
    A single SVG document.
*/
struct SVGDocumentRecord {
public:
@nogc:
    ushort startGlyph;
    ushort endGlyph;
    string data;

    /**
        Gets whether the SVG record is valid.
    */
    bool isValid() { return data.length > 0; }

    /**
        Frees the document record.
    */
    void free() {
        nu_freea(data);
    }
}