/**
    Hairetsu Font Manager

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.fontmgr;

version(linux):

import hairetsu.family;
import hairetsu.font;
import hairetsu.face;
import nulib.collections;
import nulib.string;
import numem;
/**
    Font Managers handle the lifetimes of font objects.
*/
abstract
class HaFontManager : NuRefCounted {
@nogc:
public:
    this() { this.reload(); }

    /**
        Creates a new font manager instance.
    */
    static HaFontManager create() @trusted => ha_fontmanager_new();

    /**
        Reloads the font family index.
    */
    abstract void reload() @safe;

    /**
        Enumerates the font families loaded.
    
        The memory is owned by the font manager and should not be
        freed.
    */
    abstract @property HaFontFamily[] fontFamilies() @safe;
}




//
//          C INTERFACE
//

/**
    Creates a new font manager.
*/
extern(C)
extern HaFontManager ha_fontmanager_new() @nogc;

/**
    Increases the font manager's refcount.
*/
extern(C)
HaFontManager ha_fontmanager_retain(HaFontManager fm) @nogc {
    return cast(HaFontManager)fm.retain();
}

/**
    Decreases the font manager's refcount.
*/
extern(C)
HaFontManager ha_fontmanager_release(HaFontManager fm) @nogc {
    return cast(HaFontManager)fm.release();
}
