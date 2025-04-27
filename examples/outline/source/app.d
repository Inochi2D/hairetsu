module app;
import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;

import nulib.io.stream.memstream;
import std.conv : to;
import hairetsu.shaper.basic;
import hairetsu.render;

void main(string[] args) {
	if (args.length != 4) {
		writeln("metrics <font> <pt size> <string>");
		return;
	}
	
	ha_init();

		float ptSize;
		ndstring text;

		if (!stdfile.exists(args[1])) {
			writeln(args[1], " not found...");
			return;
		}


		try {
			ptSize = args[2].to!float;
		} catch(Exception ex) {
			ptSize = 18;
		}

		// Load font.
		auto stream = nogc_new!MemoryStream(cast(ubyte[])stdfile.read(args[1]).nu_dup);
		HaFontFile file = HaFontFile.fromStream(stream, args[1]);
		HaFont font = file.fonts[0];
		HaFontFace face = font.createFace();
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
		HaFontMetrics fmetrics = face.faceMetrics();

		// 12% taller just to account for stuff like commas.
		HaCanvas canvas = nogc_new!HaCanvas(cast(uint)textSize.x, cast(uint)(textSize.y*1.12), HaColorFormat.CBPP8);
		renderer.antialiased = false;
		renderer.render(face, glyphRun, vec2(0, fmetrics.ascender.x), canvas);

		canvas.dumpToFile();

		glyphRun.release();
		renderer.release();
		canvas.release();
		face.release();
		file.release();
	ha_shutdown();
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