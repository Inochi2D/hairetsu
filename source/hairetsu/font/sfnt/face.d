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


/**
    A SFNT-derived font face.
*/
class SFNTFontFace : FontFace {
protected:
@nogc:

    /**
        Implemented by the font face to read the face.
    */
    override void onFaceLoad(FontReader reader) { }
    
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