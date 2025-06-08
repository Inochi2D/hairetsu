module hairetsu.font.collection;
import hairetsu.font.font;
import numem;

/**
    A collection of fonts.
*/
abstract
class FontCollection : NuRefCounted {
public:
@nogc:

    /**
        The fonts within the collection
    */
    abstract @property Font[] fonts();
}
