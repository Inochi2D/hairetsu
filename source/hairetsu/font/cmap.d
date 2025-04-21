/**
    Hairetsu Character Mapping Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.cmap;
import nulib.collections;
import nulib.text.unicode;
import hairetsu.common;
import numem;

/**
    A unicode character range.
*/
struct HaCharRange {
@nogc:
    
    /**
        Starting codepoint of the range.
    */
    codepoint start;
    
    /**
        Ending codepoint of the range.
    */
    codepoint end;
}

/**
    A character mapping table.
*/
abstract
class HaCharMap : NuObject {
@nogc:
public:

    /**
        Gets whether the charmap has a specified codepoint.

        Params:
            code =  The codepoint to query.
        
        Returns:
            $(D true) if the codepoint was found in the charmap,
            $(D false) otherwise.
    */
    abstract bool hasCodepoint(codepoint code);

    /**
        Gets whether the font has a specified range of codepoints.

        Params:
            range =  The range of codepoints to query.
        
        Returns:
            $(D true) if the range is within the supported ranges
            of the charmap, $(D false) otherwise.
    */
    abstract bool hasCodeRange(HaCharRange range);

    /**
        Gets the glyph index for the specified code point.

        Params:
            code =  The codepoint to query.

        Returns:
            The index of the glyph in the charmap or
            $(D GLYPH_UNKOWN)
    */
    abstract GlyphIndex getGlyphIndex(codepoint code);
}
