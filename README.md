# Hairetsu
Hairetsu (配列 /haiɾetsɯ/, sequence/arrangement in Japanese) provides cross-platform text 
lookup, shaping and blitting services on top of system APIs. 
Making building D applications with complex font and text shaping support easier.

The API is relatively closely built to resemble the harfbuzz and CoreText APIs, which are also used internally.
While under normal circumstances you may have used harfbuzz and its backends, building those
and linking them in, in a D context ends up being bothersome.

As such Hairetsu uses the underlying text shaping of the OS to make linking easier.

Hairetsu is built around reference counted types built ontop of `numem`; despite this the types provided
by hairetsu should be usable in a GC context.

## Why nogc?

The Inochi2D Project is moving towards a mainly nogc codebase, as such existing libraries around which relies
on the D garbage collector are not suitable for our usecase.

Additionally a work-in-progress C ABI is being added aswell, allowing other programming languages to access
the facilities of hairetsu to easily abstract the system level text shaping APIs.

## Which systems are supported?

There's currently 3 planned backends in the works:
 * POSIX Backend; uses harfbuzz, FreeType and FontConfig internally.
 * Darwin Backend; uses CoreText.
 * Win32 Backend; Uses Uniscribe and GDI32.