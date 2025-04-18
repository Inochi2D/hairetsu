module hairetsu.font.types;
import nulib.text.unicode;
import nulib.collections;
import nulib.string;

/**
    Text Baseline
*/
enum HaTextBaseline : uint {
    top,
    hanging,
    middle,
    alphabetic,
    bottom
}

struct HaMetrics {
    
    /**
        The horizontal advance, in glyph units.
    */
    float hAdvance;
    
    /**
        The vertical advance, in glyph units.
    */
    float vAdvance;
    
    /**
        The leftmost extent, in glyph units.
    */
    float xMinExtent;
    
    
    /**
        The rightmost extent, in glyph units.
    */
    float xMaxExtent;
    
    /**
        The topmost extent, in glyph units.
    */
    float yMinExtent;
    
    
    /**
        The bottommost extent, in glyph units.
    */
    float yMaxExtent;
}