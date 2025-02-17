/**
    Buffers

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.buffer;
import hairetsu.common;
import numem;

@nogc:

/**
    Glyph Information.
*/
struct GlyphInfo {
    uint codepoint;
    uint cluster;
}

/**
    Position of a glyph
*/
struct GlyphPosition {
    uint xAdvance;
    uint yAdvance;
    uint xOffset;
    uint yOffset;
}

/**
    A multipurpose buffer.
*/
export
class Buffer : NuRefCounted {
@nogc:
private:
    GlyphInfo[] buffer;
    bool isShaped_;

    void grow(size_t toSize) {
        if (toSize > buffer.length)
            buffer.nu_resize(toSize);
    }

public:
    
    /**
        The script of the text.
    */
    Script script = Script.Unknown;

    /**
        The direction the text is read in.
    */
    TextDirection direction = TextDirection.leftToRight;
    
    /**
        The IETF BCP 47 language tag specifying which language
        the text is written in.
    */
    string language;

    /**
        The length of the buffer in bytes.
    */
    @property uint length() {
        return cast(uint)buffer.length;
    }

    /**
        Gets whether the buffer contains already shaped glyphs.
    */
    @property bool isShaped() {
        return isShaped_;
    }

    /**
        Creates a new empty buffer.
    */
    this() { }

    /**
        Creates a copy of the given buffer

        Params:
            src = The source buffer to copy from.
    */
    this(ref Buffer src) {
        this.script = src.script;
        
        // Make a copy of buffer store.
        this.buffer.nu_resize(src.buffer.length);
        this.buffer[0..$] = src.buffer[0..$];
    }

    /**
        Clears the buffer.
    */
    void clear() {
        buffer.nu_resize(0);
        script = Script.Unknown;
        direction = TextDirection.leftToRight;
    }
}