import std.stdio;
import hairetsu;

void main() {
	auto collection = FontCollection.createFromSystem(false);

	foreach(i, ref family; collection.families) {
		writefln("%s: %s (%s faces)", i, family.familyName, family.faces.length);
		foreach(j, face; family.faces) {
			writefln("    %s: %s", j, face.name);
		}
	}
	collection.release();
}
