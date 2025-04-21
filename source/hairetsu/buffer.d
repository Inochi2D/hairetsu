/**
    Buffers

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.buffer;
import nulib.text.unicode;
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
final
class HaBuffer : NuRefCounted {
@nogc:
private:
    GlyphInfo[] buffer;
    bool isShaped_;

    // Grows the buffer and returns the index of the
    // starting location of the newly created space.
    size_t grow(size_t growBy) {
        size_t i = buffer.length;
        buffer = buffer.nu_resize(buffer.length+growBy);
        return i;
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
    Tag language = LANG_DFLT0;

    /**
        The length of the buffer in bytes.
    */
    @property uint length() { return cast(uint)buffer.length; }

    /**
        Gets whether the buffer contains already shaped glyphs.
    */
    @property bool isShaped() { return isShaped_; }

    /*
        Destructor
    */
    ~this() {
        this.clear();
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
    this(ref HaBuffer src) {
        this.script = src.script;
        
        // Make a copy of buffer store.
        this.buffer.nu_resize(src.buffer.length);
        this.buffer[0..$] = src.buffer[0..$];
    }

    /**
        Adds a string of UTF8 text to the buffer

        Params:
            text =  The text to add to the buffer.

        Returns:
            Whether the operation succeeded.
        
        Note:
            You can only add text to a unshaped buffer,
            if you wish to reuse a buffer that has been
            shaped, make sure to call $(D reset) first.
    */
    bool addUTF8(string text) {
        if (this.isShaped_)
            return false;
        
        ndstring u32 = toUTF32(text);
        size_t ix = this.grow(u32.length);
        foreach(i, dchar c; u32[]) {
            this.buffer[ix+i].codepoint = cast(codepoint)c;
        }

        return true;
    }

    /**
        Adds a string of UTF16 text to the buffer

        Params:
            text =  The text to add to the buffer.

        Returns:
            Whether the operation succeeded.
        
        Note:
            You can only add text to a unshaped buffer,
            if you wish to reuse a buffer that has been
            shaped, make sure to call $(D reset) first.
    */
    bool addUTF16(wstring text) {
        if (this.isShaped_)
            return false;

        ndstring u32 = toUTF32(text);
        size_t ix = this.grow(u32.length);
        foreach(i, dchar c; u32[]) {
            this.buffer[ix+i].codepoint = cast(codepoint)c;
        }

        return true;
    }

    /**
        Adds a string of UTF16 text to the buffer

        Params:
            text =  The text to add to the buffer.

        Returns:
            Whether the operation succeeded.
        
        Note:
            You can only add text to a unshaped buffer,
            if you wish to reuse a buffer that has been
            shaped, make sure to call $(D reset) first.
    */
    bool addUTF32(dstring text) {
        if (this.isShaped_)
            return false;
        
        size_t ix = this.grow(text.length);
        foreach(i, dchar c; text) {
            this.buffer[ix+i].codepoint = cast(codepoint)c;
        }

        return true;
    }

    /**
        Clears all state from the buffer, allowing it
        to be reused.
    */
    void clear() {
        if (this.buffer) {
            this.buffer = buffer.nu_resize(0);
            this.isShaped_ = false;

            this.script = Script.Unknown;
            this.direction = TextDirection.leftToRight;
            this.language = LANG_DFLT0;
        }
    }

    /**
        Takes ownership of the data in the buffer.

        When ownership is taken, the state of the buffer
        is reset, if you wish to reuse the buffer, you will
        need to supply the script, direction and language
        tags again.

        Returns:
            The slice of glyphs in the buffer, if the buffer
            is already shaped, returns $(D null).
    
        Note:
            This function is generally only called 
            internally by the implementation.
    */
    GlyphInfo[] take() {
        if (!this.isShaped_) {
            auto buf = this.buffer;

            // Reset the overall state.
            this.buffer = null;
            this.script = Script.Unknown;
            this.direction = TextDirection.leftToRight;
            this.language = LANG_DFLT0;
            return buf;
        }

        return null;
    }

    /**
        Gives the bufer the ownership of a now, shaped buffer.

        Params:
            info =  The glyph info slice containing the now shaped
                    glyph IDs

        Returns:
            Whether the operation succeeded.
    
        Note:
            A buffer needs to be empty before it can be given
            ownership of a shaped object. This function is 
            generally only called internally by the 
            implementation.
    */
    bool giveShaped(ref GlyphInfo[] info) {
        if (this.buffer)
            return false;
        
        this.isShaped_ = true;
        this.buffer = info;
        info = null;
        return true;
    }
}