/**
    Shaper Interface

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.shaper;

/**
    The underlying shaper subsystem
*/
extern
final
class Shaper : NuRefCounted {
@nogc:
    void shape(ref Buffer buffer);
}