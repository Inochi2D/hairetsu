module hairetsu.font.collection;
import hairetsu.font.font;
import hairetsu.common;
import numem;

/**
    A font family used during font enumeration.
*/
abstract
class FontFamily : NuRefCounted {
public:
@nogc:

    /**
        Name of the font family.
    */
    abstract @property string name();

    /**
        The fonts that belong to the font family.
    */
    abstract @property VirtualFont[] fonts();

}

/**
    A virtual font, in other words one that isn't by itself
    usable; a $(D Font) object must be created from it. 
*/
abstract
class VirtualFont : NuRefCounted {
public:
@nogc:
    
    /**
        Name of the font.
    */
    abstract @property string name();
    
    /**
        The faces within the font.
    */
    abstract @property string[] faces();

    /**
        The sample string to show for a given font.
    */
    abstract @property string sampleString();

    /**
        Realizes the virtual font into an actual font object.
    */
    abstract Font realize();
}

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
