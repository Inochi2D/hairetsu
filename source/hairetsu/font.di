/**
    Font Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module source.hairetsu.font;
import hairetsu.face;
import hairetsu.common;
import numem;

/**
    A Font is the logical representation of a set of characters
    within a font face combined with settings affecting rendering.
*/
extern
class Font : NuRefCounted {
@nogc:

    /**
        Constructs a new font from a loaded font face.
    */
    this(FontFace src);

    /**
        Constructs a copy of the specified font.
    */
    this(Font src);

    /**
        Gets a glyph for the specified codepoint and variation selector.

        Params:
            codepoint = The unicode code point to query
            variation = A variation selector codepoint.
        
        Returns:
            The glyph index, or $(D INVALID_GLYPH) on failure.
    */
    GlyphIndex getGlyph(uint codepoint, uint variation = 0);

    /**
        Gets whether the font contains the specified glyph modified
        with the specified variation selector.

        Params:
            codepoint = The unicode code point to query
            variation = A variation selector codepoint.
        
        Returns:
            $(D true) if the glyph was found, $(D false) otherwise.
    */
    bool hasGlyph(uint codepoint, uint variation = 0);

    /**
        The horizontal pixels-per-em value currently
        set for the font.
    */
    @property uint ppemX();
    @property void ppemX(uint value); /// ditto

    /**
        The vertical pixels-per-em value currently
        set for the font.
    */
    @property uint ppemY();
    @property void ppemY(uint value); /// ditto

    /**
        The point-size of the font.

        Notes:
            There's 72 points in an inch.
    */
    @property float pointSize();
    @property void pointSize(float value); /// ditto

    /**
        The horizontal scale value currently
        set for the font.
    */
    @property uint scaleX();
    @property void scaleX(uint value); /// ditto

    /**
        The vertical scale value currently
        set for the font.
    */
    @property int scaleY();
    @property void scaleY(int value); /// ditto

    /**
        How much italics to apply to the font.

        Range:
            The value should be within the range of 0..1.

        Note:
            This corrosponds to the $(D "ital") tag in the
            OpenType Axis Tag Registry.
    */
    @property float italics();
    @property void italics(float value); /// ditto

    /**
        The default italics of the font.
    */
    enum DefaultItalics = 0.0f;

    /**
        How much italics to apply to the font.

        Range:
            Values must be strictly greater than zero.
        
        Note:
            This corrosponds to the $(D "opsz") tag in the
            OpenType Axis Tag Registry.
    */
    @property uint opticalSize();
    @property void opticalSize(uint value); /// ditto

    /**
        The default slant of the font.
    */
    enum DefaultOpticalSize = 100;

    /**
        How much italics to apply to the font.

        Range:
            Values must be greater than -90 and less than +90.
        
        Note:
            This corrosponds to the $(D "slnt") tag in the
            OpenType Axis Tag Registry.
    */
    @property int slant();
    @property void slant(int value); /// ditto

    /**
        The default slant of the font.
    */
    enum DefaultSlant = 0;

    /**
        How narrow or wide the font is.

        This is equivalent to setting how condensed or extended the font is.

        Range:
            Values must be strictly greater than zero.
        
        Note:
            This corrosponds to the $(D "wdth") tag in the
            OpenType Axis Tag Registry.
    */
    @property int width();
    @property void width(int value); /// ditto

    /**
        The default variation width of the font.
    */
    enum DefaultWidth = 100;

    /**
        The weight of the font.

        In other words, how thick or bold it is.

        Range:
            Values must be in the range 1 to 1000.
        
        Note:
            This corrosponds to the $(D "wght") tag in the
            OpenType Axis Tag Registry.
    */
    @property uint weight();
    @property void weight(uint value); /// ditto

    /**
        The default weight of the font.
    */
    enum DefaultWeight = 400;
}
