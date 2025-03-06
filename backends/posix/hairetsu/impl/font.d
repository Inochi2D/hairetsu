/**
    Hairetsu Posix Fonts

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.impl.font;
import hairetsu.impl.face;
import hairetsu.backend.hb;
import hairetsu.backend.ft;
import hairetsu.backend.fc;

import hairetsu.font;
import hairetsu.face;
import hairetsu.fontmgr;
import nulib.collections;
import nulib.string;
import numem;
