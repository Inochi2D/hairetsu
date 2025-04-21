/**
    OpenType Language Tags

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.ot.lang;
import hairetsu.ot.tag;
import std.json;

/**
    Special default tag that normally won't be present in fonts.
*/
enum Tag LANG_DFLT0 = ISO15924!("DFLT");
enum Tag LANG_DFLT1 = ISO15924!("dflt"); /// ditto

/**
    Language tag that indicates an unknown or invalid language
    specification.
*/
enum Tag LANG_NONE = 0x00;

/**
    Converts a BCP47 language tag to a OpenType Language tag.

    Matches are case insensitive.
*/
Tag fromBCP47(string bcp47) @nogc nothrow {
    import nulib.text : toLower, isUpper;

    // NOTE:    If something ends with fonipa, just assume IPPH.
    //          This is a fast path for phonetic transcription.
    //          fonipa is also only a subtag, so the bcp47 string 
    //          would have to be longer.
    enum bcpFONIPA = "-fonipa";
    if (bcp47.length > bcpFONIPA.length && bcp47[$-bcpFONIPA.length..$] == bcpFONIPA)
        return ISO15924!("IPPH");


    // NOTE:    To make matches case insensitive we copy up to 24 characters
    //          into a temporary buffer all converted to lowercase.
    char[24] tmp;
    uint minLength = cast(uint)(bcp47.length < tmp.length ?
        bcp47.length :
        tmp.length);
    
    import nulib.c.stdio : printf;
    foreach(i; 0..minLength) tmp[i] = toLower(bcp47[i]);
    


    // NOTE:    This is where the compile-time code generation begins.
    //          First we load the JSON from file, then we exploit the fact
    //          That at compile time, we can still use libphobos to iterate
    //          over the JSON object, the format of the JSON is described here:
    //          https://github.com/jclark/lang-ietf-opentype
    //
    //          The inline getMultiMappings function will not be present in the
    //          output build, as it's basically a no-op if it's not running during
    //          compile time. The function is there to work around issues with just
    //          iterating with static foreach directly. The rest of the code-gen
    //          uses string mixins to generate code that can be nogc and nothrow.
    //          Note that in general, Hairetsu wants to keep use of string mixins
    //          to a minimum as they have a relatively high memory footprint. 
    import std.format : format;
    import std.json;

    enum mappingRoot = parseJSON(import("langmap.json")).object();
    pragma(msg, "Parsing ", cast(int)mappingRoot.length, " BCP47 language mappings...");

    string[2][] getMultiMappings(JSONValue[] values) {
        if (__ctfe) {
            string[2][] mappings;
            for (size_t i = 0; i < cast(ptrdiff_t)values.length-1; i += 2) {
                mappings ~= [values[i].str, values[i+1].str];
            }
            return mappings;
        } else return null;
    }

    switch(cast(string)tmp[0..minLength]) {
        static foreach(string key, JSONValue language; mappingRoot) {
            static if (language.type == JSONType.array) {
                static foreach(mapping; getMultiMappings(language.array[1..$])) {
                    mixin(q{case "%s-%s": return ISO15924!("%s");}.format(key, mapping[0], mapping[1]));
                }

                mixin(q{case "%s": return ISO15924!("%s");}.format(key, language.array[0].str()));
            } else static if (language.type == JSONType.string) {

                mixin(q{case "%s": return ISO15924!("%s");}.format(key, language.str()));
            } else static assert(0, "Format error.");
        }

        default:
            return LANG_NONE;
    }
}

@("fromBCP47")
unittest {
    assert(fromBCP47("zh-HANS") == ISO15924!("ZHS"));
    assert(fromBCP47("zh-hant") == ISO15924!("ZHT"));
    assert(fromBCP47("zh-latn") == ISO15924!("ZHP"));
    assert(fromBCP47("zh-HK") == ISO15924!("ZHH"));
    assert(fromBCP47("zh-MO") == ISO15924!("ZHT"));
    assert(fromBCP47("zh") == ISO15924!("ZHS"));
    assert(fromBCP47("da-fonipa") == ISO15924!("IPPH"));
    assert(fromBCP47("us-fonipa") == ISO15924!("IPPH"));

    // Technically not valid, but we currently just assume anything that
    // ends with -fonipa is always a phonetic language.
    assert(fromBCP47("aaaaa-fonipa") == ISO15924!("IPPH"));
}