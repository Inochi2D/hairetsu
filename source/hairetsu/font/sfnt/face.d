/**
    Hairetsu SFNT Face Object

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font.sfnt.face;
import hairetsu.font.sfnt;
import hairetsu.common;
import hairetsu.font;

import nulib.text.unicode;
import nulib.collections;
import nulib.string;
import numem;
import std.regex;

import hairetsu.font.tables.glyf;



/**
    A SFNT-derived font face.
*/
abstract
class SFNTFontFace : FontFace {
protected:
@nogc:
    
    /**
        The reader instance
    */
    SFNTReader reader;

    /**
        Implemented by the font face to read the face.
    */
    override
    void onFaceLoad(FontReader reader) {        
        this.reader = cast(SFNTReader)reader;
    }
    
public:
    
    /**
        The font entry.
    */
    final
    @property SFNTFontEntry entry() { return (cast(SFNTFont)parent).entry; }

    /**
        Constructs a font face.
    */
    this(Font parent, FontReader reader) {
        super(parent, reader);
    }
}