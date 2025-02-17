/**
    Coretext Font

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetrsu.font;
import hairetsu.face;
import hairetsu.common;
import numem;


export
class Font : NuRefCounted {
@nogc:

    this(FontFace src);
    this(Font src);

    GlyphIndex getGlyph(uint codepoint, uint variation = 0);

    bool hasGlyph(uint codepoint, uint variation = 0);

    @property uint ppemX();
    @property void ppemX(uint value); /// ditto

    @property uint ppemY();
    @property void ppemY(uint value); /// ditto

    @property float pointSize();
    @property void pointSize(float value); /// ditto

    @property uint scaleX();
    @property void scaleX(uint value); /// ditto

    @property int scaleY();
    @property void scaleY(int value); /// ditto

    @property float italics();
    @property void italics(float value); /// ditto

    @property uint opticalSize();
    @property void opticalSize(uint value); /// ditto

    @property int slant();
    @property void slant(int value); /// ditto

    @property int width();
    @property void width(int value); /// ditto

    @property uint weight();
    @property void weight(uint value); /// ditto

}