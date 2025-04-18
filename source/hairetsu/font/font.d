/**
    Hairetsu Font Object Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.font;
import hairetsu.font.reader;
import hairetsu.font.face;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;

/**
    A Font Object
*/
abstract
class HaFont : NuRefCounted {
@nogc:
private:
    uint index_;

protected:
    
    /**
        Implemented by the font face to read the face.
    */
    abstract void onFaceLoad(HaFontReader reader);
    
public:

    /**
        Index of face within font file.
    */
    final @property size_t index() { return index_; }

    /**
        Constructs a new font face from a stream.
    */
    this(uint index, HaFontReader reader) {
        this.index_ = index;
        this.onFaceLoad(reader);
    }

    /**
        The postscript name of the font face.
    */
    abstract @property string name();

    /**
        The font family of the font face.
    */
    abstract @property string family();

    /**
        The sub font family of the font face.
    */
    abstract @property string subfamily();

    /**
        The name of the type of font.
    */
    abstract @property string type();

    /**
        Amount of glyphs within font face.
    */
    abstract @property size_t glyphCount();

    /**
        Units per EM.
    */
    abstract @property uint upem();

    /**
        Fills all of the unicode codepoints that the face supports,
        and writes them to the given set.

        Params:
            cSet = The set to fill.

        Returns:
            The amount of codepoints that were added to the set.
    */
    abstract uint fillCodepoints(ref set!codepoint cSet);
}