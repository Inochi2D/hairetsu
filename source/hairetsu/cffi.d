/**
    Hairetsu C FFI Interface.

    This generally should not be used by code written in D and is mainly provided
    to allow using the library from other languages.

    All base objects exposed by hairetsu are reference counted and **MUST** be managed
    with the provided $(D ha_retain) and $(D ha_release) methods.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.cffi;
import hairetsu.font.file;
import hairetsu.font.font;
import hairetsu.font.face;
import hairetsu.font.cmap;
import hairetsu.glyph;

// Extern deps used internally.
import nulib.string;
import numem : NuRefCounted;

extern(C) export:

//
//      LIBRARY INITIALIZATION.
//

/**
    Gets whether hairetsu is initialized.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
bool ha_get_initialized() @nogc nothrow {
    import hairetsu : haIsInitialized;
    return haIsInitialized();
}

/**
    Attempts to initialize hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
bool ha_try_initialize() @nogc {
    import hairetsu : haTryInitialize;
    return haTryInitialize();
}

/**
    Attempts to shut down hairetsu manually,
    should normally not be called, as the C Runtime
    should call the initializer automatically.

    Returns:
        $(D true) if initialized,
        $(D false) otherwise.
*/
extern(C)
void ha_try_shutdown() @nogc {
    import hairetsu : haTryShutdown;
    return haTryShutdown();
}

//
//      MEMORY MANAGMENT.
//

/**
    Retains a reference to a hairetsu object.

    Params:
        obj = The object to retain.
*/
void ha_retain(void* obj) {
    (cast(NuRefCounted)obj).retain();
}

/**
    Retains a reference to a hairetsu object.

    Params:
        obj = The object to retain.
    
    Returns:
        The resulting handle after the operation,
        $(D null) if the object was freed.
*/
void* ha_release(void* obj) {
    return cast(void*)(cast(NuRefCounted)obj).release();
}


//
//      FONT FILES.
//


/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_fontfile_t;

/**
    Creates a new font for the given memory slice

    Params:
        data =  The memory slice to read the font data from.
        length = The lengty of the memory slice to read the data from.
    
    Returns:
        A $(D ha_fontfile_t*) instance on success,
        $(D null) on failure.
    
    Note:
        This function will copy the memory out of data,
        this is to ensure ownership of the data is properly handled.
*/
ha_fontfile_t* ha_fontfile_from_memory(ubyte* data, uint length) {
    return cast(ha_fontfile_t*)HaFontFile.fromMemory(data[0..length]);
}

/**
    Creates a new font for the given memory slice with a given name.

    Params:
        data =  The memory slice to read the font data from.
        length = The lengty of the memory slice to read the data from.
        name = The name to give the memory sliced font.
    
    Returns:
        A $(D ha_fontfile_t*) instance on success,
        $(D null) on failure.
    
    Note:
        This function will copy the memory out of data,
        this is to ensure ownership of the data is properly handled.
*/
ha_fontfile_t* ha_fontfile_from_memory_with_name(ubyte* data, uint length, const(char)* name) {
    nstring nname = name;
    return cast(ha_fontfile_t*)HaFontFile.fromMemory(data[0..length], nname);
}

/**
    Creates a new font for the given file path

    Params:
        path =  Path to the file containing the font, in
        null-terminate UTF8 encoding.
    
    Returns:
        A $(D HaFontFile) instance on success,
        $(D null) on failure.
*/
ha_fontfile_t* ha_fontfile_from_file(const(char)* path) {
    nstring npath = path;
    return cast(ha_fontfile_t*)HaFontFile.fromFile(npath);
}

/**
    Gets the type name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of the type of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
const(char)* ha_fontfile_get_type(ha_fontfile_t* obj) {
    if (!obj)
        return null;
    
    return (cast(HaFontFile)obj).type.ptr;
}

/**
    Gets the name of the font file, in UTF-8 encoding.

    Params:
        obj = The object to query.
    
    Returns:
        Name of font contained within the font file
        in UTF-8 encoding; $(D null) if obj is invalid.
*/
const(char)* ha_fontfile_get_name(ha_fontfile_t* obj) {
    if (!obj)
        return null;
    
    return (cast(HaFontFile)obj).name.ptr;
}

/**
    Gets the list of fonts within the file.

    Params:
        obj = The object to query.
        target = Where to store the array.

    Returns:
        Unsigned 32-bit integer length of the font objects
        owned by the font file; the returned array should
        NOT be freed by the caller.
*/
uint ha_fontfile_get_fonts(ha_fontfile_t* obj, ha_font_t** target) {
    *target = cast(ha_font_t*)((cast(HaFontFile)obj).fonts.ptr);
    return cast(uint)(cast(HaFontFile)obj).fonts.length;
}


//
//      FONT OBJECTS
//


/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_font_t;

/**
    Gets the postscript name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The postscript name in UTF-8 format.
*/
const(char)* ha_font_get_name(ha_font_t* obj) {
    return (cast(HaFont)obj).name.ptr;
}

/**
    Gets the family name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The family name in UTF-8 format.
*/
const(char)* ha_font_get_family(ha_font_t* obj) {
    return (cast(HaFont)obj).family.ptr;
}

/**
    Gets the subfamily name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The subfamily name in UTF-8 format.
*/
const(char)* ha_font_get_subfamily(ha_font_t* obj) {
    return (cast(HaFont)obj).subfamily.ptr;
}

/**
    Gets the type name of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The type name in UTF-8 format.
*/
const(char)* ha_font_get_type(ha_font_t* obj) {
    return (cast(HaFont)obj).type.ptr;
}

/**
    Gets amount of glyphs stored within the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font.
*/
uint ha_font_get_glyph_count(ha_font_t* obj) {
    return cast(uint)(cast(HaFont)obj).glyphCount;
}

/**
    Gets Units per EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
uint ha_font_get_upem(ha_font_t* obj) {
    return (cast(HaFont)obj).upem;
}

/**
    Gets lowest recommended pixels-per-EM of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The lowest recommended pixels-per-EM for readability.
*/
uint ha_font_get_lowest_ppem(ha_font_t* obj) {
    return (cast(HaFont)obj).lowestPPEM;
}

/**
    Gets the global metrics of the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        The global metrics.
*/
HaFontMetrics ha_font_get_global_metrics(ha_font_t* obj) {
    return (cast(HaFont)obj).fontMetrics;   
}

/**
    Gets the base ID of a glyph within the font associated
    with the given code point.
    
    Params:
        obj = The object to query.
        codepoint = The Unicode code point of the glyph.
    
    Returns:
        The glyph ID for the given codepoint, or 
        $(D GLYPH_MISSING) if not found.
*/
uint ha_font_find_glyph(ha_font_t* obj, uint codepoint) {
    return (cast(HaFont)obj).charMap.getGlyphIndex(codepoint);
}

/**
    Gets the metrics for the given glyph ID.
    
    Params:
        obj = The object to query.
        glyphId = The ID of the glyph to query.
    
    Returns:
        The base metrics of the given glyph.
*/
HaGlyphMetrics ha_font_glyph_metrics_for(ha_font_t* obj, uint glyphId) {
    return (cast(HaFont)obj).getMetricsFor(glyphId);
}

/**
    Creates a new face object from the font.
    
    Params:
        obj = The object to query.
    
    Returns:
        A reference to a newly created face object,
        or $(D null) on failure.
*/
ha_face_t* ha_font_create_face(ha_font_t* obj) {
    return cast(ha_face_t*)((cast(HaFont)obj).createFace());
}


//
//      FACE OBJECTS
//


/**
    Opaque handle to Hairetsru Font File.
*/
struct ha_face_t;

/**
    Gets Units per EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The Units per EM.
*/
uint ha_face_get_upem(ha_face_t* obj) {
    return (cast(HaFontFace)obj).upem;
}

/**
    Gets scale of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scale factor.
*/
float ha_face_get_scale(ha_face_t* obj) {
    return (cast(HaFontFace)obj).scale;
}

/**
    Gets pixels-per-EM of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The pixels-per-EM.
*/
float ha_face_get_ppem(ha_face_t* obj) {
    return (cast(HaFontFace)obj).ppem;
}

/**
    Gets amount of glyphs stored within the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The amount of glyphs stored within the font face.
*/
uint ha_face_get_glyph_count(ha_face_t* obj) {
    return (cast(HaFontFace)obj).glyphCount;
}

/**
    Gets the face which is used when the given face does not
    contain a glyph.
    
    Params:
        obj = The object to query.
    
    Returns:
        A weak reference to the fallback face, or
        $(D null) if no fallback is specified.
*/
ha_face_t* ha_face_get_fallback(ha_face_t* obj) {
    return cast(ha_face_t*)(cast(HaFontFace)obj).fallback;
}

/**
    Sets the face which is used when the given face does not
    contain a glyph. The face can belong to a different font.
    
    Params:
        obj = The object to query.
        face = The face to use as a fallback.
    
    Note:
        The face may not create an infinite self-referential chain.
        If this is the case the operation will set the fallback to
        $(D null)!
*/
void ha_face_set_fallback(ha_face_t* obj, ha_face_t* face) {
    (cast(HaFontFace)obj).fallback = cast(HaFontFace)face;
}

/**
    Gets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
    
    Returns:
        Whether hinting is requested.
*/
bool ha_face_get_hinting(ha_face_t* obj) {
    return (cast(HaFontFace)obj).wantHinting;
}

/**
    Sets whether hinting is requested for the face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_hinting(ha_face_t* obj, bool value) {
    (cast(HaFontFace)obj).wantHinting = value;
}

/**
    Gets the dots-per-inch of the font face, defaults to 96.

    By default this value is 96, to comply with the reference CSS DPI,
    if you're rendering to paper or the display has DPI information,
    this value needs to be changed.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set DPI.
*/
float ha_face_get_dpi(ha_face_t* obj) {
    return (cast(HaFontFace)obj).dpi;
}

/**
    Sets the dots-per-inch of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_dpi(ha_face_t* obj, float value) {
    (cast(HaFontFace)obj).dpi = value;
}

/**
    Gets the point size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_pt(ha_face_t* obj) {
    return (cast(HaFontFace)obj).pt;
}

/**
    Sets the point size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_pt(ha_face_t* obj, float value) {
    (cast(HaFontFace)obj).pt = value;
}

/**
    Gets the pixel size of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The current set point size.
*/
float ha_face_get_px(ha_face_t* obj) {
    return (cast(HaFontFace)obj).px;
}

/**
    Sets the pixel size of the font face.
    
    Params:
        obj = The object to query.
        value = The value to set.
*/
void ha_face_set_px(ha_face_t* obj, float value) {
    (cast(HaFontFace)obj).px = value;
}

/**
    Gets the scaled global metrics of the font face.
    
    Params:
        obj = The object to query.
    
    Returns:
        The scaled global metrics.
*/
HaFontMetrics ha_face_get_global_metrics(ha_face_t* obj) {
    return (cast(HaFontFace)obj).faceMetrics;   
}
