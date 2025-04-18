module hairetsu.shaper.hb;
import hairetsu.shaper;
import hairetsu.common;
import numem;

version(Have_hairetsu_harfbuzz):

/**
    A harfbuzz based text shaper.
*/
class HaHarfbuzzShaper : HaShaper {
@nogc:
public:

    /**
        Shape a buffer of text.

        Params:
            buffer =    The buffer to shape.
    */
    override
    void shape(ref HaBuffer buffer) {

    }
    
}
