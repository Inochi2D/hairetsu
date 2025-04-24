# Hairetsu
Hairetsu (配列 /haiɾetsɯ/, sequence/arrangement in Japanese) provides cross-platform text 
lookup, shaping and blitting services on top of system APIs. 
Making building D applications with complex font and text shaping support easier.

Hairetsu is built around reference counted types built ontop of `numem`; despite this the types provided
by hairetsu should be usable in a GC context.

## Loading Fonts

Hairetsu includes its own font reading and rendering mechanism, to load a font you first create a `HaFontFile` instance.
A couple of convenience functions are provided to do this.

Font Files are the top level object of Hairetsu's font ownership hirearchy; ownership is managed internally by hairetsu,
as such you should not attempt to manually destroy objects unless the documentation tells you to.

From these font files you can create `HaFont` objects, which represent the logical font within a font file container,
some containers can contain **multiple** fonts within a single file, such as TTC containers.

```d
HaFontFile myFile = HaFontFile.fromFile("notosans.ttf");
HaFont myFont = myFile.fonts[0]; // Gets the first font within the file.

writeln(myFont.type, " ", myFile.type); // Likely would print "TrueType SFNT"
```

## Looking up glyphs

Generally you should refer to a text shaper to find glyph IDs for your target language,
but Hairetsu does provide the essentials for looking up glyphs by character, however this
will be **without** substitutions unless you write code to fetch those.

A `HaCharMap` is provided by fonts which allows looking up glyph indices from eg. the `CMAP`
table in TTF and OTF fonts. If a font does not contain a glyph for the given character code,
the `.notdef` glyph index will be returned instead, a convenience `GLYPH_MISSING` enum is provided
to help you check this case.

```d
GlyphIndex i = myFont.charMap.getGlyphIndex('あ');
```

## Faces
When using a font it's often desired to be able to configure properties about the font without needing
to repeatedly reload a font to do so; the `HaFontFace` facilitates this by being a type which refers
back in to the parent font that created it.

This allows you to, for example, set style, sizing, hinting requirements, etc. for the glyph data
you wish to fetch from the font. You can have as many font faces loaded at a time as you want.

```d

// Create a font face, scaled to half of the base size.
HaFontFace myFace = myFont.createFace();
myFace.scale.x = 0.5;
myFace.scale.y = 0.5;
```

### Acknowledgements
Language tag mapping is based on the map table created by `jclark`.

https://github.com/jclark/lang-ietf-opentype

Some inspiration has been taken from various renderers, such as fontdue, canvas_ity and others.  
The glyph rendering algorithm is more or less an amalgamation of them all, with smaller tweaks,
using signed converage masks (note; NOT SDFs) to effectively render glyphs.