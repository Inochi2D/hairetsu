/**
    Buffers

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.shaper.buffer;
import hairetsu.shaper;
import nulib.text.unicode;
import hairetsu.common;
import numem;

@nogc:

/**
    The predominant reading direction for text shaping.

    You can AND these flags together, but vertical will
    take precedence if declared.
*/
enum HaTextDirection : ubyte {
    
    /**
        Text is read left-to-right
    */
    leftToRight = 0b0001,
    
    /**
        Text is read right-to-left
    */
    rightToLeft = 0b0011,

    /**
        Text is read top to bottom
    */
    topToBottom = 0b0100,

    /**
        Text is read bottom to top
    */
    bottomToTop = 0b1100,
}

/**
    Gets whether a text direction is specified as horizontal
*/
pragma(inline, true)
bool isHorizontal(HaTextDirection direction) @safe @nogc nothrow {
    return (direction & 0b0011) > 0;
}

/**
    Gets whether a text direction is specified as vertical
*/
pragma(inline, true)
bool isVertical(HaTextDirection direction) @safe @nogc nothrow {
    return (direction & 0b1100) > 0;
}

/**
    A multipurpose buffer.
*/
final
class HaBuffer : NuRefCounted {
@nogc:
private:
    GlyphIndex[] buffer_;
    bool isShaped_;

    // Grows the buffer and returns the index of the
    // starting location of the newly created space.
    size_t grow(size_t growBy) @trusted {
        size_t i = buffer.length;
        buffer_ = buffer_.nu_resize(buffer_.length+growBy);
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
    HaTextDirection direction = HaTextDirection.leftToRight;
    
    /**
        The IETF BCP 47 language tag specifying which language
        the text is written in.
    */
    Tag language = LANG_DFLT0;

    /**
        The length of the buffer in bytes.
    */
    @property uint length() @safe { return cast(uint)buffer_.length; }

    /**
        Gets whether the buffer contains already shaped glyphs.
    */
    @property bool isShaped() @safe { return isShaped_; }

    /**
        A slice of the contents of the buffer.
    */
    @property GlyphIndex[] buffer() @system { return buffer_; }

    /*
        Destructor
    */
    ~this() @safe {
        this.clear();
    }

    /**
        Creates a new empty buffer.
    */
    this() @safe { }

    /**
        Creates a copy of the given buffer

        Params:
            src = The source buffer to copy from.
    */
    this(ref HaBuffer src) @trusted {
        this.script = src.script;
        this.buffer_ = src.buffer_.nu_dup;
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
    bool addUTF8(string text) @trusted {
        if (this.isShaped_)
            return false;
        
        ndstring u32 = toUTF32(text);
        size_t ix = this.grow(u32.length);
        foreach(i, dchar c; u32[]) {
            this.buffer_[ix+i].codepoint = cast(codepoint)c;
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
    bool addUTF16(wstring text) @trusted {
        if (this.isShaped_)
            return false;

        ndstring u32 = toUTF32(text);
        size_t ix = this.grow(u32.length);
        foreach(i, dchar c; u32[]) {
            this.buffer_[ix+i].codepoint = cast(codepoint)c;
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
    bool addUTF32(dstring text) @safe {
        if (this.isShaped_)
            return false;
        
        size_t ix = this.grow(text.length);
        foreach(i, dchar c; text) {
            this.buffer_[ix+i].codepoint = cast(codepoint)c;
        }

        return true;
    }

    /**
        Clears all state from the buffer, allowing it
        to be reused.
    */
    void clear() @trusted {
        if (this.buffer_) {
            this.buffer_ = buffer_.nu_resize(0);
            this.isShaped_ = false;

            this.script = Script.Unknown;
            this.direction = HaTextDirection.leftToRight;
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
    codepoint[] take() @safe {
        if (!this.isShaped_) {
            auto buf = this.buffer_;

            // Reset the overall state.
            this.buffer_ = null;
            this.script = Script.Unknown;
            this.direction = HaTextDirection.leftToRight;
            this.language = LANG_DFLT0;
            return buf;
        }

        return null;
    }

    /**
        Gives the bufer the ownership of a now, shaped buffer.

        Params:
            glyphs =    The glyph info slice containing the now shaped
                        glyph IDs

        Returns:
            Whether the operation succeeded.
    
        Note:
            A buffer needs to be empty before it can be given
            ownership of a shaped object. This function is 
            generally only called internally by the 
            implementation.
    */
    bool giveShaped(ref GlyphIndex[] glyphs) @safe {
        if (this.buffer_)
            return false;
        
        this.isShaped_ = true;
        this.buffer_ = glyphs;
        glyphs = null;
        return true;
    }
}