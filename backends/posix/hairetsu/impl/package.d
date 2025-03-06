/**
    Hairetsu Posix Backend

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.backend.impl;
import hairetsu.backend.fc;
import hairetsu.backend.ft;

/**
    Gets whether hairetsu is initialized.
*/
extern(C)
export bool ha_get_initialized() @nogc {
    return _ha_initialized;
}

/**
    Initializes hairetsu.
*/
extern(C)
export bool ha_initialize() @nogc {
    if (!_ha_initialized) {
        if (!FcInit())
            return false;
        
        _ha_initialized = FT_Init_FreeType(&_ha_ft_library) == 0;
    }

    return _ha_initialized;
}

/**
    Shuts down hairetsu.
*/
extern(C)
extern void ha_shutdown() @nogc {
    if (_ha_initialized) {
        FcFini();
        FT_Done_FreeType(_ha_ft_library);
        _ha_initialized = false;
    }
}

extern(C)
export FT_Library _ha_get_freetype() @nogc {
    return _ha_ft_library;
}

private __gshared bool _ha_initialized = false;
private __gshared FT_Library _ha_ft_library;