/**
    Hairetsu (配列 /haiɾetsɯ/, sequence/arrangement in Japanese) provides cross-platform text 
    lookup, shaping and blitting services on top of system APIs. 
    Making building D applications with complex font and text shaping support easier.

    The API is relatively closely built to resemble the harfbuzz and CoreText APIs, which are also used internally.
    While under normal circumstances you may have used harfbuzz and its backends, building those
    and linking them in, in a D context ends up being bothersome.

    As such Hairetsu uses the underlying text shaping of the OS to make linking easier.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu;