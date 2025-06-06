/**
    Hairetsu Text Layouting Subsystem

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.layout;
import hairetsu.font.face;
import hairetsu.glyph;
import hairetsu.common;

import numem;

/**
    The orientation of glyphs in a text segment.
*/
enum HaLayoutGravity : uint {
    
    /**
        Southern (upright) gravity.
    */
    south   = 0x00,
    
    /**
        Eastern gravity.
    */
    east    = 0x01,
    
    /**
        Northen (upside-down) gravity.
    */
    north   = 0x02,
    
    /**
        Western gravity.
    */
    west    = 0x03,

    /**
        Scripts will use the natural gravity based on the
        base gravity of the script.
    */
    natural = 0x00,

    /**
        Forces the base gravity to always be used, regardless
        of script.
    */
    strong  = 0x08,

    /**
        For scripts not in their natural direction (eg. Latin in East gravity), 
        choose per-script gravity such that every script respects the line progression.
    */
    line    = 0x0F
}

/**
    Text reading direction.
*/
enum HaLayoutDirection : uint {
    
    /**
        Text is read left-to-right
    */
    leftToRight = 1,
    
    /**
        Text is read right-to-left
    */
    rightToLeft = 2,

    /**
        Text direction is weak, meaning it may change mid-run.
    */
    weak = 4,
}

/**
    Hairetsu Layouting Engine
*/
class HaLayoutEngine : NuRefCounted {
protected:
@nogc:

    // // Iterates through every font and font fallback
    // // to find a face which can render the given glyph.
    // final
    // ref Glyph getRenderableGlyph(ref FontFace face, codepoint code) {
    //     GlyphIndex bestIndex;
    //     FontFace bestFace = face;

    //     do {
    //         bestFace.findGlyphFor(code, bestIndex, bestFace);
            
    //         if (bestIndex == GLYPH_MISSING)
    //             break;
            
    //         Glyph* glyph = &face.getGlyph(bestIndex);
    //         if (canRender(*glyph))
    //             return *glyph;


    //         // Manually iterate one down, otherwise
    //         // we'd repeatedly just get the same face.
    //         bestFace = bestFace.fallback;
    //     } while (bestFace !is null);
    //     return face.getGlyph(bestIndex);
    // }

public:

}
