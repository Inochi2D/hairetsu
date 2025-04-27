import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;
import std.array : join;

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
					"    %u: %s %s (%u glyphs, %s with %s outlines)", 
					font.index, 
					font.family, 
					font.subfamily, 
					font.glyphCount, 
					font.type,
					font.outlineTypeNames
				);
				writefln("      - Features: (%u) '%s'", font.fontFeatures.length, font.fontFeatures().join("', '"));
			}
		}
	}
	ha_shutdown();
}
