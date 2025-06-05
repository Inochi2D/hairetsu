module app;

import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;
import std.conv : to;

void main(string[] args) {
	if (args.length <= 3) {
		writeln("metrics <font> <pt size> <string...>");
		return;
	}

	// Load font.
	if (!stdfile.exists(args[1])) {
		writeln(args[1], " not found...");
		return;
	}
	auto stream = nogc_new!MemoryStream(cast(ubyte[])stdfile.read(args[1]).nu_dup);
	HaFontFile file = HaFontFile.fromStream(stream, args[1]);

	// Get point size
	float ptSize = args[2].to!float;

	// Get codepoints
	ndstring[] strings;
	foreach(arg; args[3..$])
		strings ~= toUTF32(arg);
	
	// Do the listing.
	foreach(HaFont font; file.fonts) {
		auto face = font.createFace();
		face.pt = ptSize;
		
		writefln(
			"%u: %s (%s) (dpi=%s, pt=%s, px=%s):", 
			font.index, 
			font.name,
			font.type,
			face.dpi,
			face.pt,
			face.px
		);

		foreach(str; strings) {

			foreach(dchar c; str) {
				auto aIdx = font.charMap.getGlyphIndex(c);
				if (aIdx == GLYPH_MISSING) {
					writefln(
						"        '%s' (%x): (no glyph)",
						c,
						aIdx,
					);
					continue;
				}

				auto aMetrics = face.getGlyph(aIdx).metrics;
				writefln(
					"        '%s' (%x): (advance=<%s, %s>, bearing=<%s, %s>)", 
					c, 
					aIdx,
					cast(float)aMetrics.advance.x,
					cast(float)aMetrics.advance.y,
					cast(float)aMetrics.bearingH.x,
					cast(float)aMetrics.bearingV.y
				);
			}
		}

		face.release();
	}
}
