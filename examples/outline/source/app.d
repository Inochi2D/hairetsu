module app;
import std.stdio;
import stdfile = std.file;
import hairetsu;
import numem;
import nulib.io.stream.memstream;
import std.conv : to;

import hairetsu.glyph;
import canvasity;
import gamut;

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

		text = toUTF32(args[3]);

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

		HaVec2!float textSize = face.measureText(text);

		Image image;
		Canvasity canvas;
		image.create(cast(int)textSize.x, cast(int)textSize.y, PixelType.rgba8);
		canvas = Canvasity(image);

		canvas.strokeStyle("#FFFFFF");
		canvas.fillStyle("#FFFFFF");
		canvas.lineWidth(2);

		HaFontMetrics fmetrics = face.faceMetrics;
		canvas.translate(0, textSize.y+cast(float)fmetrics.descender.x);
		foreach(dchar c; text) {
			GlyphIndex glyphIndex = font.charMap.getGlyphIndex(c);
			HaGlyph glyph = face.getGlyph(glyphIndex);
			
			if (c == ' ') {

				// idk why I need to multiply it by 2 here to get
				// it looking right. Need to investigate.
				auto metrics = face.getMetricsFor(glyphIndex);
				canvas.translate(cast(float)metrics.advance.x*2, 0);
				continue;
			}
			
			canvas.beginPath();
			foreach(HaOutlineOp op; glyph.data.outline.commands) {

				final switch(op.opcode) {

					case HaOutlineOpCode.moveTo:
						canvas.moveTo(
							op.target.x,
							op.target.y
						);
						break;
						
					case HaOutlineOpCode.lineTo:
						canvas.lineTo(
							op.target.x, 
							op.target.y
						);
						break;
						
					case HaOutlineOpCode.quadTo:
						canvas.quadraticCurveYo(
							op.control1.x, 
							op.control1.y, 
							op.target.x, 
							op.target.y
						);
						break;
						
					case HaOutlineOpCode.cubicTo:
						canvas.bezierCurveTo(
							op.control1.x, 
							op.control1.y, 
							op.control2.x, 
							op.control2.y, 
							op.target.x, 
							op.target.y
						);
						break;
						
					case HaOutlineOpCode.closePath:
						canvas.closePath();
						break;
				}
			}
			canvas.fill();

			canvas.translate(cast(float)glyph.metrics.advance.x, 0);
		}

		image.saveToFile("output.png");

		face.release();
		file.release();
	ha_shutdown();
}

HaVec2!float measureText(HaFontFace face, dstring text) {
	HaVec2!float cursor;
	GlyphIndex glyphIndex;
	HaGlyphMetrics metrics;
	HaFontMetrics fmetrics = face.faceMetrics;

	glyphIndex = face.parent.charMap.getGlyphIndex(text[0]);
	metrics = face.getMetricsFor(glyphIndex);
	float bearingX = cast(float)metrics.bearingH.x;

	foreach(dchar c; text) {
		glyphIndex = face.parent.charMap.getGlyphIndex(c);
		metrics = face.getMetricsFor(glyphIndex);

		float height = cast(float)metrics.size.y;
		float advanceX = cast(float)metrics.advance.x;

		if (c == ' ')
			advanceX *= 2;

		// Increase height if neccesary.
		if (height > cursor.y)
			cursor.y = cast(float)metrics.size.y;

		cursor.x += advanceX;
	}

	cursor.y -= cast(float)(fmetrics.descender.x*2);
	cursor.x += bearingX;
	return cursor;
}