/**
    Hairetsu Posix Fonts

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.impl.face;
import hairetsu.impl : _ha_get_freetype;
import hairetsu.backend.hb;
import hairetsu.backend.ft;
import hairetsu.backend.fc;

import hairetsu.family;
import hairetsu.face;
import hairetsu.font;
import nulib.collections;
import nulib.string;
import numem;

/**
    A POSIX Font Face.
*/
class PosixFontFace : HaFontFace {
@nogc:
private:
    hb_face_t* hb_face;
    FT_Face ft_face;

public:
    ~this() {
        if (hb_face)
            hb_face_destroy(hb_face);
        
        if (ft_face)
            FT_Done_Face(ft_face);
    }

    this(FT_Face ft_face) {
        this.ft_face = ft_face;
        this.hb_face = hb_ft_face_create_referenced(ft_face);
    }
    
}






//
//          C INTERFACE
//

extern(C)
HaFontFace ha_fontface_from_descriptor(ref HaFontDescriptor descriptor) @nogc {
    auto pattern = cast(FcPattern*)descriptor.handle;
    FT_Face face;

    if (FcPatternGetFTFace(pattern, FC_FTFACE, 0, &face) == FcResult.Match) {
        return nogc_new!PosixFontFace(face);
    }

    if (auto file = pattern.getPatternStr(FC_FILE)) {
        auto findex = pattern.getPatternInteger(FC_INDEX);

        if (FT_New_Face(_ha_get_freetype(), file.ptr, findex, &face) == 0)
            return nogc_new!PosixFontFace(face);
    }

    // Failed.
    return null;
}

extern(C)
HaFontFace ha_fontface_from_file(nstring path, uint index) @nogc {
    
    FT_Face face;
    if (FT_New_Face(_ha_get_freetype(), path.ptr, index, &face) == 0)
        return nogc_new!PosixFontFace(face);

    // Failed.
    return null;
}

extern(C)
HaFontFace ha_fontface_from_memory(ubyte[] memory, uint index) @nogc {

    FT_Face face;
    if (FT_New_Memory_Face(_ha_get_freetype(), memory.ptr, memory.length, index, &face) == 0)
        return nogc_new!PosixFontFace(face);

    // Failed.
    return null;
}
