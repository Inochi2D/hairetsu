/**
    Hairetsu Posix Font Manager

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.backend.fontmgr;
import hairetsu.backend.font;
import hairetsu.backend.face;
import hairetsu.backend.family;
import hairetsu.backend.fc;
import hairetsu.backend;

import hairetsu.font;
import hairetsu.face;
import hairetsu.family;
import hairetsu.fontmgr;
import nulib.collections;
import nulib.string;
import numem;

extern(C)
export HaFontManager ha_fontmanager_new() @nogc {
    if (!ha_get_initialized())
        ha_initialize();
    
    return nogc_new!PosixFontManager();
}

class PosixFontManager : HaFontManager {
@nogc:
private:
    vector!PosixFontFamily families;
    FcFontSet* fontset;




    //
    //          FC STATE
    //
    void clearFcState() @trusted {
        if (fontset) {
            FcFontSetDestroy(fontset);
            fontset = null;
        }

        if (!families.empty) {
            foreach_reverse(ref family; families)
                nogc_delete(family);
            families.clear();
        }
    }

    void enumerateFc() @trusted {
        this.clearFcState();

        auto pat = FcPatternCreate();
        auto os = FcObjectSetBuild(

            // Font Base Info
            FC_FAMILY, 
            FC_STYLE, 
            FC_CHARSET,
            FC_LANG, 
            
            // Font style info
            FC_WEIGHT,
            FC_SLANT,
            FC_WIDTH,

            // Font meta info
            FC_FONTFORMAT,
            FC_VARIABLE,
            FC_SPACING,
            FC_SCALABLE,
            FC_COLOR,

            // Font Instance
            FC_FTFACE,
            FC_FILE,
            FC_INDEX,
            FC_LIST_END
        );

        fontset = FcFontList(null, pat, os);

        FcObjectSetDestroy(os);
        FcPatternDestroy(pat);
    }


    //
    //          FAMILY BUILDER
    //
    void rebuildFamilies() @trusted {
        this.clearFcState();
        this.enumerateFc();

        weak_map!(string, PosixFontFamily) familyGroups;
	    foreach(i; 0..fontset.nfont) {        
    		FcPattern* face = fontset.fonts[i];
        
            string familyName = face.getPatternStr(FC_FAMILY);
            if (!familyName)
                continue;

            // Add family group.
            if (familyName !in familyGroups)
                familyGroups[familyName] = nogc_new!PosixFontFamily(familyName);
            
            auto family = familyGroups[familyName];
            family.addFcFace(face);
        }

        foreach(family; familyGroups.byValue()) {
            this.families ~= family;
        }
    }
    
public:
    ~this() { this.clearFcState(); }
    this() { super(); }

    override
    void reload() @safe {
        this.rebuildFamilies();
    }

    override 
    @property HaFontFamily[] fontFamilies() @trusted { 
        return cast(HaFontFamily[])families[];
    }
}