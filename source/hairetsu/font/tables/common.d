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
    Hmtx/Vmtx Metrics record
*/
struct MtxRecord {
    ushort advance;
    short bearing;
}