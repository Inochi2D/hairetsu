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
class SFNTFontFile : FontFile {
@nogc:
protected:

    /**
        Implemented by the font file reader to index the faces.
    */
    override
    void onIndexFont(ref weak_vector!Font fonts) {
        foreach(ref SFNTFontEntry entry; (cast(SFNTReader)reader).fontEntries) {
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
    this(SFNTReader reader, string name = "<memory stream>") {
        super(reader, name);
    }
}
