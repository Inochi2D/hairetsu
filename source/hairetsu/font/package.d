/**
    Hairetsu Font System

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.font;

public import hairetsu.font.file;
public import hairetsu.font.font;
public import hairetsu.font.face;
public import hairetsu.font.cmap;
public import hairetsu.font.glyph;
public import hairetsu.font.collection;
public import hairetsu.ot.tables;
public import hairetsu.font.types;


/**
    Initializes the font loader subsystem.
*/
extern(C)
bool ha_init_fonts() @nogc {
    import hairetsu : haIsInitialized;
    if (haIsInitialized) 
        return true;

    import hairetsu.font.reader : ha_init_fonts_reader;
    if (!ha_init_fonts_reader())
        return false;
    
    return true;
}

/**
    Initializes the font loader subsystem.
*/
extern(C)
bool ha_shutdown_fonts() @nogc {
    import hairetsu : haIsInitialized;
    if (!haIsInitialized) 
        return true;

    import hairetsu.font.reader : ha_shutdown_fonts_reader;
    if (!ha_shutdown_fonts_reader())
        return false;
    
    return true;
}
