module app;
import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;

import nulib.io.stream.memstream;
import std.conv : to;
import hairetsu.shaper.basic;
import hairetsu.render;

Font findFont(string nameOrFile) {
	import std.algorithm.searching : startsWith;
	import std.string : chompPrefix;
	import std.uni : toLower;

	// Lookup file?
	if (stdfile.exists(nameOrFile)) {
		if (FontFile file = FontFile.fromFile(nameOrFile)) {
			Font font = file.fonts[0].retained;
			file.release();
			return font;
		}
	}
	
	// NOTE:	In a function that wouldn't just be called once you'd want
	// 			to cache this.
	FontCollection fc = FontCollection.createFromSystem();
	
	// Lookup by name?
	foreach(family; fc.families) {
		string lcName = nameOrFile.toLower();
		string faName = family.familyName.toLower();

		if (faName.startsWith(lcName) || lcName.startsWith(faName)) {
			uint bestMatchIdx = 0;
			uint bestMatchDivergence = uint.max;
			
			// DirectWrite limitation (currently).
			if (family.faces[0].name.length == 0) {
				writefln("Font is missing name, matched first instance of %s...", family.familyName);
				return family.faces[bestMatchIdx].realize();
			}
			
			foreach(i, face; family.faces) {
				string fcName = face.name.toLower();
				string fcStripped = fcName.chompPrefix(lcName);
				if (fcStripped.length < bestMatchDivergence) {
					bestMatchIdx = cast(uint)i;
					bestMatchDivergence = cast(uint)fcStripped.length;
				}
			}

			if (bestMatchDivergence != 0) {
				writefln("Using best match %s...", family.faces[bestMatchIdx].name);
			}

			return family.faces[bestMatchIdx].realize();
		}
	}

	return null;
}

int main(string[] args) {
	if (args.length != 4) {
		writeln("metrics <font> <pt size> <string>");
		return -1;
	}

	float ptSize;
	try {
		ptSize = args[2].to!float;
	} catch(Exception ex) {
		ptSize = 18;
	}

	// Load font.
	Font font = findFont(args[1]);
	if (!font) { writeln(args[1], " not found..."); return -1; }

	FontFace face = font.createFace();
	face.pt = ptSize;

	// Create a new run.
	HaBuffer glyphRun = nogc_new!HaBuffer();
	glyphRun.addUTF8(args[3]);
	
	// Shape the text.
	HaBasicShaper shaper = nogc_new!HaBasicShaper();
	shaper.shape(face, glyphRun);
	shaper.release();

	// Create canvas and renderer.
	HaRenderer renderer = HaRenderer.createBuiltin();
	vec2 textSize = renderer.measureGlyphRun(face, glyphRun);
	FontMetrics fmetrics = face.faceMetrics();

	HaCanvas canvas = nogc_new!HaCanvas(cast(uint)textSize.x, cast(uint)(textSize.y+fmetrics.ascender.x), HaColorFormat.CBPP8);
	renderer.render(face, glyphRun, vec2(0, fmetrics.ascender.x), canvas);

	canvas.dumpToFile();

	glyphRun.release();
	renderer.release();
	canvas.release();
	face.release();
	return 0;
}

/**
	Dumps the canvas to file using gamut.
*/
void dumpToFile(ref HaCanvas canvas) {
	import gamut : Image, PixelType;
	Image img = Image(canvas.width, canvas.height, PixelType.l8);

	foreach(y; 0..canvas.height) {
		ubyte[] source = cast(ubyte[])canvas.scanline(y);
		ubyte[] destination = cast(ubyte[])img.scanline(y);
		destination[0..$] = source[0..$];
	}
	img.saveToFile("output.png");
}