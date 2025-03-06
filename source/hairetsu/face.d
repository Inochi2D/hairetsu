/**
    Hairetsu Context

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.face;
import hairetsu.family;

import nulib.collections;
import nulib.string;
import numem;

/**
    A font face.
*/
abstract
class HaFontFace : NuRefCounted {
@nogc:
public:

    /**
        Creates a new font face from a descriptor.
    */
    static HaFontFace fromDescriptor(ref HaFontDescriptor descriptor) {
        return ha_fontface_from_descriptor(descriptor);
    }
    
    /**
        Creates a new font face from a file path.
    */
    static HaFontFace fromFile(string path, uint index = 0) {
        return ha_fontface_from_file(nstring(path), index);
    }
    
    /**
        Creates a new font face from a memory slice containing a font.
    */
    static HaFontFace fromMemory(ubyte[] data, uint index = 0) {
        return ha_fontface_from_memory(data, index);
    }
    
}





//
//          C INTERFACE
//

/**
    Creates a new font face from a descriptor.
*/
extern(C)
extern HaFontFace ha_fontface_from_descriptor(ref HaFontDescriptor descriptor) @nogc;

/**
    Creates a new font face from a file path.
*/
extern(C)
HaFontFace ha_fontface_from_file(nstring path, uint index) @nogc;

/**
    Creates a new font face from a memory slice containing a font.
*/
extern(C)
HaFontFace ha_fontface_from_memory(ubyte[] data, uint index) @nogc;

/**
    Increases the font manager's refcount.
*/
extern(C)
HaFontFace ha_fontface_retain(HaFontFace fm) @nogc {
    return cast(HaFontFace)fm.retain();
}

/**
    Decreases the font manager's refcount.
*/
extern(C)
HaFontFace ha_fontface_release(HaFontFace fm) @nogc {
    return cast(HaFontFace)fm.release();
}