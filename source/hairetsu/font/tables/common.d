/**
    OpenType Common Tables

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: 
        https://learn.microsoft.com/en-us/typography/opentype/spec/otff, 
        https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2
*/
module hairetsu.font.tables.common;
public import hairetsu.common;
public import numem : nu_resize;

/**
    An OpenType Tag.
*/
alias Tag = uint;

/**
    Allocates an array
*/
T[] ha_allocarr(T)(size_t size) @nogc {
    import numem : nogc_initialize;

    T[] buffer;
    buffer = buffer.nu_resize(size);
    nogc_initialize(buffer[0..$]);
    return buffer;
}

/**
    Frees an array
*/
void ha_freearr(T)(ref T[] arr) @nogc {
    arr = arr.nu_resize(0);
}

/**
    Hmtx/Vmtx Metrics record
*/
struct MtxRecord {
    ushort advance;
    short bearing;
}