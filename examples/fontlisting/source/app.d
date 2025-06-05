import std.stdio;
import hairetsu;

void main() {
	auto fontManager = FontManager.create();

	writeln(fontManager.fontFamilies());
	foreach(i, ref family; fontManager.fontFamilies()) {
		writefln("%s: %s (%s faces)", i, family.familyName, family.faces.length);
		foreach(j, face; family.faces) {
			writefln("    %s: %s", j, face);
		}
		
	}
	fontManager.release();
}
