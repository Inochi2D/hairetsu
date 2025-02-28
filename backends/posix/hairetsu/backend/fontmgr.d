/**
    Hairetsu Posix Font Manager

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.backend.fontmgr;
import hairetsu.backend.font;
import hairetsu.backend.face;
import hairetsu.backend.fc;

import hairetsu.font;
import nulib.collections;
import nulib.string;
import numem;

extern(C)
export HaFontManager ha_fontmanager_new() @nogc {
    return nogc_new!PosixFontManager();
}

class PosixFontManager : HaFontManager {
@nogc:
private:
    vector!PosixFontFace faces;
public:

    override 
    HaFontFamily[] enumerateFontFamilies() { return null; }

    /**
        Adds a font to the font manager.
    */
    override
    void addFontFace(HaFontFace face) {
        faces ~= face;
    }
}