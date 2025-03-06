/**
    Hairetsu Posix Backend

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.backend;
import hairetsu.backend.fc;

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
        _ha_initialized = FcInit();
    }

    return _ha_initialized;
}

/**
    Shuts down hairetsu.
*/
extern(C)
extern void ha_shutdown() @nogc {
    if (_ha_initialized)
        FcFini();
}

private __gshared bool _ha_initialized = false;