<p align="center">
    <img src="hairetsu.png" alt="NuMem" style="height: 50%; max-height: 512px; width: auto;">
</p>  

*Rendered with Hairetsu using Noto Sans JP*

# Hairetsu
Hairetsu (配列 /haiɾetsɯ/, sequence/arrangement in Japanese) provides cross-platform text 
lookup, shaping and rasterization with plans for complex text layout and bidi in the pipeline.

Hairetsu is built around reference counted types built ontop of `numem`; despite this the types provided
by hairetsu should be usable in a GC context.

# Building and Packaging
Hairetsu uses the `dub` build system and package manager during the build process.
When using hairetsu in D code you can just simply add it as a D dependency.
If you wish to use hairetsu outside of DLang, you can compile a shared/dynamic library using the `-dynamic` variants
of the configurations.

## On Linux, FreeBSD, etc.
```
dub build --build=release --config=posix-dynamic
```

## On Windows
```
dub build --build=release --config=win32-dynamic
```

## On macOS (and derived)
```
dub build --build=release --config=appleos-dynamic
```

The shared object will be put in `out/`, a C FFI interface is provided in [cffi.d](source/hairetsu/cffi.d).

## Enumerating System Fonts

Hairetsu has a subsystem for enumerating fonts on the system and their capabilities.
To facilitate this, Hairetsu provides "collections". Collections cover fonts and their variants.

You can get a collection of all fonts that the OS is aware of by calling `FontCollection.createFromSystem`,
this function will only list fonts which Hairetsu can realize to actual font objects and will omit non-realizable fonts.

For example, to select the first font that supports a given unicode code point, 
you can use `FontFamily.getFirstFaceWith` to query each face in the collection for a UTF-32 character.

FontFaceInfo's can be realised to their font file using `FontFaceInfo.realize`; some fonts might not be
realizable. Use `FontFaceInfo.isRealizable` to query this.

```d
// Note:  You can pass in a boolean to tell Hairetsu whether to ask the OS
//        to reindex its font list.
FontCollection systemFonts = FontCollection.createFromSystem();
FontFile selectedFont;
foreach(family; systemFonts.families) {
    if (FontFaceInfo face = family.getFirstFaceWith('あ')) {
        selectedFont = face.realize();
        break;
    }
}
```

#### NOTE
This will only work on systems where a backend is implemented; otherwise you will get an empty collection.

## Loading Fonts

Hairetsu includes its own font reading and rendering mechanism, to load a font you first create a `FontFile` instance.
A couple of convenience functions are provided to do this.

Font Files are the top level object of Hairetsu's font ownership hirearchy; ownership is managed internally by hairetsu,
as such you should not attempt to manually destroy objects unless the documentation tells you to.

From these font files you can create `Font` objects, which represent the logical font within a font file container,
some containers can contain **multiple** fonts within a single file, such as TTC containers.

```d
FontFile myFile = FontFile.fromFile("notosans.ttf");
Font myFont = myFile.fonts[0]; // Gets the first font within the file.

writeln(myFont.type, " ", myFile.type); // Likely would print "TrueType SFNT"
```

## Looking up glyphs

Generally you should refer to a text shaper to find glyph IDs for your target language,
but Hairetsu does provide the essentials for looking up glyphs by character, however this
will be **without** substitutions unless you write code to fetch those.

A `CharMap` is provided by fonts which allows looking up glyph indices from eg. the `CMAP`
table in TTF and OTF fonts. If a font does not contain a glyph for the given character code,
the `.notdef` glyph index will be returned instead, a convenience `GLYPH_MISSING` enum is provided
to help you check this case.

```d
GlyphIndex i = myFont.charMap.getGlyphIndex('あ');
```

## Faces
When using a font it's often desired to be able to configure properties about the font without needing
to repeatedly reload a font to do so; the `FontFace` facilitates this by being a type which refers
back in to the parent font that created it.

This allows you to, for example, set style, sizing, hinting requirements, etc. for the glyph data
you wish to fetch from the font. You can have as many font faces loaded at a time as you want.

```d

// Create a font face, scaled to half of the base size.
FontFace myFace = myFont.createFace();
myFace.scale.x = 0.5;
myFace.scale.y = 0.5;
```

### Acknowledgements
Language tag mapping is based on the map table created by `jclark`.

https://github.com/jclark/lang-ietf-opentype

Some inspiration has been taken from various renderers, such as fontdue, canvas_ity and others.  
The glyph rendering algorithm is more or less an amalgamation of them all, with smaller tweaks,
using signed converage masks (note; NOT SDFs) to effectively render glyphs.