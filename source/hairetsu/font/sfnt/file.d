module hairetsu.font.sfnt.file;
import hairetsu.font.sfnt.reader;
import hairetsu.font.sfnt.font;
import hairetsu.font.file;
import hairetsu.font.font;
import hairetsu.common;

import nulib.collections;
import numem;

/**
    SFNT-based Font File
*/
class SFNTFontFile : HaFontFile {
@nogc:
protected:

    /**
        Implemented by the font file reader to index the faces.
    */
    override
    void onIndexFont(ref weak_vector!HaFont fonts) {
        foreach(ref SFNTFontEntry entry; (cast(SFNTReader)reader).fontEntries) {
            switch(entry.type) {
                case SNFTFontType.openType:

                    import hairetsu.font.ot : OTFont;
                    fonts ~= nogc_new!OTFont(entry, reader);
                    break;

                case SNFTFontType.trueType:

                    import hairetsu.font.tt : TTFont;
                    fonts ~= nogc_new!TTFont(entry, reader);
                    break;

                // Not supported for now.
                case SNFTFontType.postScript:
                default:
                    fonts ~= nogc_new!SFNTUnknownFont(entry, reader);
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
    this(SFNTReader reader, string name = "<memory stream>") {
        super(reader, name);
    }
}
