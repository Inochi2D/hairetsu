/**
    Hairetsu (配列 /haiɾetsɯ/, sequence/arrangement in Japanese) provides cross-platform text 
    lookup, shaping and blitting services on top of system APIs. 
    Making building D applications with complex font and text shaping support easier.

    The API is relatively closely built to resemble the harfbuzz and CoreText APIs, which are also used internally.
    While under normal circumstances you may have used harfbuzz and its backends, building those
    and linking them in, in a D context ends up being bothersome.

    As such Hairetsu uses the underlying text shaping of the OS to make linking easier.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu;

public import hairetsu.fontmgr;
public import hairetsu.shaper;
public import hairetsu.common;
public import hairetsu.glyph;
public import hairetsu.font;

/**
    Whether Hairetsu is initialized.
*/
bool haIsInitialized() @nogc nothrow {
    return _ha_initialized;
}

/**
    Attempts to initialize hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.
*/
bool haTryInitialize() @nogc {
    if (!_ha_initialized) {

        // Initialize the fonts subsystem.
        if (!ha_init_fonts())
            return false;

        _ha_initialized = true;
    }
    return _ha_initialized;
}

/**
    Attempts to shut down hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.
*/
void haTryShutdown() @nogc {
    if (_ha_initialized) {
        cast(void)ha_shutdown_fonts();
        _ha_initialized = false;
    }
}

private
extern(C):

// Whether hairetsu is initialized.
__gshared bool _ha_initialized = false;

//
//      CRT Hooks
//

pragma(crt_constructor)
void _ha_crt_ctor() @nogc { cast(void)haTryInitialize(); }

pragma(crt_destructor)
void _ha_crt_dtor() @nogc { haTryShutdown(); }