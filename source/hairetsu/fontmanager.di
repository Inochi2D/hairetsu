/**
    Font Discovery

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.fontmanager;
import hairetsu.descriptor;
import numem;

/**
    The font manager helps finding fonts fitting specific criteria from the system.

    Descriptor Sets are used to constrain on which fonts are selected.
*/
extern
class FontManager {
@nogc:
public:

    /**
        Creates a new font manager.
    */
    this();

    /**
        Looks up fonts using the given descriptors to narrow down the
        search based on the font(s)' parameters.

        Params:
            set =   the descriptor set to use to narrow down the search,
                    can be $(D null).
        
        Returns:
            A descriptor set of fonts.
    */
    FontDescriptorSet lookup(FontDescriptorSet set);

    /**
        Convenience function which looks for a font by its PostScript/full name.

        Params:
            name =  name of the font to look for.
        
        Returns:
            A descriptor set of fonts.
    */
    FontDescriptorSet lookup(string name);

    /**
        Convenience function which looks at a descriptor set, then
        loads the font with the closest match to the given constraints.

        Params:
            set = the descriptor set to use for the lookup.
        
        Returns:
            A $(D FontFace) or $(D null) if no suitable font face was found.
    */
    FontFace lookup(FontDescriptorSet set);

    /**
        Convenience function which looks for a font by its PostScript/full name.

        Params:
            name =  name of the font to look for.
        
        Returns:
            A $(D FontFace) or $(D null) if no suitable font face was found.
    */
    FontFace lookup(string name);
}
