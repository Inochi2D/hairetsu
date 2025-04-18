import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;

void main(string[] args) {
	if (args.length <= 1) {
		writeln("fontinfo <fonts...>");
		return;
	}
	
	ha_init();
	foreach(i, arg; args[1..$]) {
		if (stdfile.exists(arg)) {
			auto stream = nogc_new!MemoryStream(cast(ubyte[])stdfile.read(arg).nu_dup);
			HaFontFile file = HaFontFile.fromStream(stream, arg);

			writefln("%u: %s (%s with %u subfonts)", i, file.name, file.type, file.fonts.length);
			foreach(HaFont font; file.fonts) {
				writefln(
					"\t%u: %s %s (%u glyphs, %s)", 
					font.index, 
					font.family, 
					font.subfamily, 
					font.glyphCount, 
					font.type
				);

				auto aIdx = font.charMap.getGlyphIndex('a');
				auto aMetrics = font.getMetricsFor(aIdx, HaDirection.horizontal);
				aMetrics.advance /= font.upem;
				aMetrics.bearing /= font.upem;

				writefln(
					"\t\t'a' (%u) metrics: (advance=%s, bearing=%s)",
					aIdx,
					cast(float)aMetrics.advance,
					cast(float)aMetrics.bearing
				);
			}
		}
	}
	ha_shutdown();
}
