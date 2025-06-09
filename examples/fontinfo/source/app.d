import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;
import std.array : join;
import nulib.io.stream.file;

void main(string[] args) {
	if (args.length <= 1) {
		writeln("fontinfo <fonts...>");
		return;
	}
	
	foreach(i, arg; args[1..$]) {
		if (stdfile.exists(arg)) {
			if (FontFile file = FontFile.fromFile(arg)) {
				writefln("%u: %s (%s with %u subfonts)", i, file.name, file.type, file.fonts.length);
				foreach(Font font; file.fonts) {
					writefln(
						"    %u: %s %s (%u glyphs)", 
						font.index, 
						font.family, 
						font.subfamily, 
						font.glyphCount
					);
					writefln("      - Format: %s", font.type);
					writefln("      - Features: (%u) '%s'", font.fontFeatures.length, font.fontFeatures().join("', '"));
				}
			}
		}
	}
}
