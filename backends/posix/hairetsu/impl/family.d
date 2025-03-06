/**
    Hairetsu Posix Font Manager

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.impl.family;
import hairetsu.impl.font;
import hairetsu.impl.face;
import hairetsu.impl;
import hairetsu.backend.fc;

import hairetsu.font;
import hairetsu.face;
import hairetsu.family;
import hairetsu.fontmgr;
import nulib.collections;
import nulib.string;
import numem;


/**
    A family of fonts.
*/
class PosixFontFamily : HaFontFamily {
@nogc:
private:
    nstring familyName_;
    vector!(HaFontDescriptor) descriptors;

public:
    this(string familyName) {
        this.familyName_ = familyName;
    }

    /**
        Name of the font family.
    */
    override
    @property string familyName() @safe {
        return familyName_[];
    }

    /**
        Enumerates all of the font faces in a family.
    */
    override
    @property HaFontDescriptor[] faces() @safe {
        return descriptors[];
    }

    //
    //              INTERNAL
    //
package(hairetsu.impl):
    void addFcFace(FcPattern* pattern) {
        HaFontDescriptor descriptor;
        descriptor.handle = pattern;
        descriptor.family = this;
        descriptor.name = pattern.getPatternStr(FC_FAMILY);
        descriptor.style = pattern.getPatternStr(FC_STYLE);
        descriptor.isVariable = pattern.getPatternBool(FC_VARIABLE);
        descriptor.isMonospaced = pattern.getPatternInteger(FC_SPACING) == FC_MONO;

        switch(pattern.getPatternStr(FC_FONTFORMAT)) {
            default: break;

            case "CFF":
            case "CFF2":
                descriptor.format = HaFontFormat.openType;
                break;
            
            case "TrueType":
                descriptor.format = HaFontFormat.trueType;
                break;
            
            case "Type 1":
                descriptor.format = HaFontFormat.type1;
                break;
        }
        this.descriptors ~= descriptor;
    }
}