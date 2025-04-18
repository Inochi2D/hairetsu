module app;

import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;

void main(string[] args) {
	if (args.length <= 2) {
		writeln("metrics <font> <h/vstring...>");
		return;
	}
	
	ha_init();


	// Load font.
	if (!stdfile.exists(args[1])) {
		writeln(args[1], " not found...");
		return;
	}
	auto stream = nogc_new!MemoryStream(cast(ubyte[])stdfile.read(args[1]).nu_dup);
	HaFontFile file = HaFontFile.fromStream(stream, args[1]);

	// Get codepoints
	ndstring[] strings;
	foreach(arg; args[2..$])
		strings ~= toUTF32(arg);
	
	// Do the listing.
	foreach(HaFont font; file.fonts) {
		writefln(
			"%u: %s (%s):", 
			font.index, 
			font.name,
			font.type
		);

		foreach(str; strings) {
			if (str.length <= 2) {
				writefln(
					"    \"%s\": (no direction specified, skipping...)",
					str,
				);
				continue;
			}

			if (str[0] != 'v' && str[0] != 'h') {
				writefln(
					"    \"%s\": (no direction specified, skipping...)",
					str,
				);
				continue;
			}

			HaDirection direction = 
				str[0] == 'v' ?
					HaDirection.vertical :
					HaDirection.horizontal;

			// Show what metrics are being displayed.
			writefln(
				"    \"%s\": (%s)",
				str[1..$],
				direction == HaDirection.horizontal ?
					"horizontal" : 
					"vertical"
			);

			foreach(dchar c; str[1..$]) {
				auto aIdx = font.charMap.getGlyphIndex(c);
				if (aIdx == GLYPH_UNKOWN) {
					writefln(
						"        '%s' (%x): (no glyph)",
						c,
						aIdx,
					);
					continue;
				}

				auto aMetrics = font.getMetricsFor(aIdx, direction);
				aMetrics.advance /= font.upem;
				aMetrics.bearing /= font.upem;
				writefln(
					"        '%s' (%x): (advance=%s, bearing=%s)", 
					c, 
					aIdx,
					cast(float)aMetrics.advance,
					cast(float)aMetrics.bearing
				);
			}
		}
	}
	ha_shutdown();
}
