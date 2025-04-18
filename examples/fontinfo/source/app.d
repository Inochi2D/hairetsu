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
			HaFont font = HaFont.createFont(stream, arg);

			writefln("%u: %s (%u faces)", i, font.name, font.faces.length);
			foreach(HaFontFace face; font.faces) {
				writefln("\t%u: %s %s (%s)", face.index, face.family, face.subfamily, face.type);
			}
		}
	}
	ha_shutdown();
}
