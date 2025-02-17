/**
    Hairetsu C API.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.c;
import hairetsu.font;
import hairetsu.face;
import numem;


//
//              SCRIPTS
//

/**
    Gets the script from its 4 character code.

    Params:
        code = 4 character code as an ASCII string.

    Returns:
        The script of the code.
*/
extern(C)
export
Script haScriptFromCode(char[4] code) {
    return *cast(Script*)(code.ptr);
}

/**
    Gets the 4 character code from its script.

    Params:
        script = The script to get the code for.

    Returns:
        The 4 character code for the script.
*/
extern(C)
export
char[4] haCodeFromScript(Script script) {
    return (cast(char*)cast(void*)script)[0..4];
}



//
//              FONTFACE
//

/**
    Adds a reference to the fontface object.

    Params:
        face = the fontface object.
*/
extern(C)
export
void haFontFaceRetain(FontFace face) {
    face.retain();
}

/**
    Releases a reference from the fontface object.

    Params:
        face = the fontface object.
    
    Returns:
        $(D true) if refcount reached 0, otherwise $(D false).
*/
extern(C)
export
bool haFontFaceRelease(FontFace face) {
    return face.release() is null;
}

/**
    Constructs a new font from a loaded font face.

    Params:
        face = the font face to use as a source.
    
    Returns:
        A newly allocated FontFace, or $(D null) on failure.
*/
extern(C)
export
FontFace haFontFaceFromFile(const(char)* path, size_t length) @nogc nothrow {
    try {
        return nogc_new!FontFace(cast(string)path[0..length]);
    } catch (Exception ex) {
        assumeNoThrow((ref Exception ex) { nogc_delete!Exception(ex); }, ex);
        return null;
    }
}






//
//              FONT
//

/**
    Adds a reference to the font object.

    Params:
        font = the font object.
*/
extern(C)
export
void haFontRetain(Font font) {
    font.retain();
}

/**
    Releases a reference from the font object.

    Params:
        font = the font object.
    
    Returns:
        $(D true) if refcount reached 0, otherwise $(D false).
*/
extern(C)
export
bool haFontRelease(Font font) {
    return font.release() is null;
}

/**
    Constructs a new font from a loaded font face.

    Params:
        face = the font face to use as a source.
    
    Returns:
        A newly allocated Font, or $(D null) on failure.
*/
extern(C)
export
Font haFontFromFace(FontFace face) @nogc nothrow {
    try {
        return nogc_new!Font(face);
    } catch (Exception ex) {
        assumeNoThrow((ref Exception ex) { nogc_delete!Exception(ex); }, ex);
        return null;
    }
}

/**
    Constructs a copy of the specified font.

    Params:
        face = the font face to use as a source.
    
    Returns:
        A newly allocated Font, or $(D null) on failure.
*/
extern(C)
export
Font haFontFromFont(Font font) @nogc nothrow {
    try {
        return nogc_new!Font(font);
    } catch (Exception ex) {
        assumeNoThrow((ref Exception ex) { nogc_delete!Exception(ex); }, ex);
        return null;
    }
}