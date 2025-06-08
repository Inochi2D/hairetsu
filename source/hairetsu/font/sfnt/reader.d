/**
    Hairetsu SFNT Reader

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.reader;
import hairetsu.common;
import hairetsu.font;
import nulib.io.stream;
import numem.core.traits : Fields, isStructLike;
import numem;

public import hairetsu.font.sfnt.font;
public import hairetsu.font.reader;

/**
    A class which handles reading tables and records from a SFNT formatted
    file, such as TrueType or OpenType fonts.
*/
class SFNTReader : FontReader {
protected:
@nogc:
    
    /**
        Called by the internal font factory to query whether the stream
        can be read.
    */
    override
    FontReader tryCreateReader(Stream stream) @system nothrow {
        try {
            return nogc_new!SFNTReader(stream);
        } catch(Exception ex) {

            if (ex !is null) {
                try {
                    nogc_delete(ex);
                } catch(Exception ex) {
                    assert(0, "Failed deleting exception!");

                    // At this point this might just go on forever,
                    // so, we'll leak.
                    return null;
                }
            }
            return null;
        }
    }

public:

    /**
        Constructs a new SFNT Reader from a stream.

        Params:
            stream =    the stream to read from, the reader takes
                        ownership of the stream given.

        Note:
            Flushable streams will be read fully and copied to a new
            MemoryStream, the SFNTFontReader becomes the owner of
            the input stream.
    */
    this(Stream stream) { super(stream); }

    /**
        Creates a font instance using this reader.
    */
    override
    FontFile createFont(string name) {
        import hairetsu.font.sfnt.file : SFNTFontFile;
        return nogc_new!SFNTFontFile(this, name);
    }
}
