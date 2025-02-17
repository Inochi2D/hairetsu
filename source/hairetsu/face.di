/**
    Font Face Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.face;
import numem;

/**
    A font face represents an OpenType font file blob.

    Fonts are created from a face.
*/
extern
class FontFace : NuRefCounted {
@nogc:
    
    /**
        Constructs a font face from the specified path.

        This function $(B MAY) throw.
    */
    this(string filePath);

    /**
        Constructs a font face from binary data provided.

        This function $(B MAY) throw.
    */
    this(ubyte[] data);
}