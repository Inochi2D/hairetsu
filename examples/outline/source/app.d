module app;
import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import renderer;

import nulib.io.stream.memstream;
import std.conv : to;
import hairetsu.shaper.basic;

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
		CanvasityRenderer renderer = nogc_new!CanvasityRenderer();
		HaVec2!float textSize = renderer.measureGlyphRun(face, glyphRun);
		GamutCanvas canvas = nogc_new!GamutCanvas(cast(uint)textSize.x, cast(uint)textSize.y);

		HaFontMetrics fmetrics = face.faceMetrics;
		renderer.render(face, glyphRun, HaVec2!float(0, textSize.y+cast(float)fmetrics.descender.x), canvas);

		canvas.saveToPNG("output.png");

		glyphRun.release();
		renderer.release();
		canvas.release();
		face.release();
		file.release();
	ha_shutdown();
}
