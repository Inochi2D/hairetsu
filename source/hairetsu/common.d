/**
    Common Hairetsu functionality and data types.

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module hairetsu.common;
public import nulib.math.fixed;
public import nulib.text.unicode;
public import nulib.string;

@nogc nothrow:

/**
    The 32-bit glyph index in a font.

    A glyph index does not match the unicode codepoint
    that it represents, it is internal to the specific font.
*/
alias GlyphIndex = uint;

/**
    Represents a missing glyph, when rendering this
    glyph should indicate to the user that a character
    is not implemented within the font.
*/
enum GlyphIndex GLYPH_MISSING = 0x0u;

/**
    An unsigned 32-bit tag.
*/
alias Tag = uint;

/**
    Converts a 4-character ISO15924 string to its numeric equivalent.

    This essentially packs the ISO14924 string into a uint. 
*/
enum Tag ISO15924(immutable(char)[4] tag) = (
    ((cast(uint)(tag[0]) & 0xFF) << 24) | 
    ((cast(uint)(tag[1]) & 0xFF) << 16) | 
    ((cast(uint)(tag[2]) & 0xFF) << 8) |
     (cast(uint)(tag[3]) & 0xFF)
);

/**
    A 2-dimensional vector.
*/
union HaVec2(T) {
@nogc:
    alias data this;
    struct {
        T x = 0;
        T y = 0;
    }
    T[2] data;
}

/**
    A bounding box
*/
struct HaRect(T) {
@nogc:
    T xMin;
    T xMax;
    T yMin;
    T yMax;
}

/**
    Text reading direction.
*/
enum TextDirection : uint {
    
    /**
        Text is read left-to-right
    */
    leftToRight = 1,
    
    /**
        Text is read right-to-left
    */
    rightToLeft = 2,

    /**
        Text direction is weak, meaning it may change mid-run.
    */
    weak = 4,
}

/**
    The orientation of glyphs in a text segment.
*/
enum TextGravity : uint {
    
    /**
        Southern (upright) gravity.
    */
    south   = 0x00,
    
    /**
        Eastern gravity.
    */
    east    = 0x01,
    
    /**
        Northen (upside-down) gravity.
    */
    north   = 0x02,
    
    /**
        Western gravity.
    */
    west    = 0x03,

    /**
        Scripts will use the natural gravity based on the
        base gravity of the script.
    */
    natural = 0x00,

    /**
        Forces the base gravity to always be used, regardless
        of script.
    */
    strong  = 0x08,

    /**
        For scripts not in their natural direction (eg. Latin in East gravity), 
        choose per-script gravity such that every script respects the line progression.
    */
    line    = 0x0F
}

/**
    Language tag for "DFLT"
*/
enum LANG_DFLT = ISO15924!("DFLT");

/**
    The various scripts supported defined in $(LINK2 https://unicode.org/iso15924/, ISO 15924).
*/
enum Script : Tag {
    
    /**
        Adlam
    */
    Adlam =                                ISO15924!("Adlm"),
    
    /**
        Caucasian Albanian
    */
    Caucasian_Albanian =                   ISO15924!("Aghb"),
    
    /**
        Ahom
    */
    Ahom =                                 ISO15924!("Ahom"),
    
    /**
        Arabic
    */
    Arabic =                               ISO15924!("Arab"),
    
    /**
        Imperial Aramaic
    */
    Imperial_Aramaic =                     ISO15924!("Armi"),
    
    /**
        Armenian
    */
    Armenian =                             ISO15924!("Armn"),
    
    /**
        Avestan
    */
    Avestan =                              ISO15924!("Avst"),
    
    /**
        Balinese
    */
    Balinese =                             ISO15924!("Bali"),
    
    /**
        Bamum
    */
    Bamum =                                ISO15924!("Bamu"),
    
    /**
        Bassa Vah
    */
    Bassa_Vah =                            ISO15924!("Bass"),
    
    /**
        Batak
    */
    Batak =                                ISO15924!("Batk"),
    
    /**
        Bengali
    */
    Bengali =                              ISO15924!("Beng"),
    
    /**
        Bhaiksuki
    */
    Bhaiksuki =                            ISO15924!("Bhks"),
    
    /**
        Bopomofo
    */
    Bopomofo =                             ISO15924!("Bopo"),
    
    /**
        Brahmi
    */
    Brahmi =                               ISO15924!("Brah"),
    
    /**
        Braille
    */
    Braille =                              ISO15924!("Brai"),
    
    /**
        Buginese
    */
    Buginese =                             ISO15924!("Bugi"),
    
    /**
        Buhid
    */
    Buhid =                                ISO15924!("Buhd"),
    
    /**
        Chakma
    */
    Chakma =                               ISO15924!("Cakm"),
    
    /**
        Canadian Aboriginal
    */
    Canadian_Aboriginal =                  ISO15924!("Cans"),
    
    /**
        Carian
    */
    Carian =                               ISO15924!("Cari"),
    
    /**
        Cham
    */
    Cham =                                 ISO15924!("Cham"),
    
    /**
        Cherokee
    */
    Cherokee =                             ISO15924!("Cher"),
    
    /**
        Chorasmian
    */
    Chorasmian =                           ISO15924!("Chrs"),
    
    /**
        Coptic
    */
    Coptic =                               ISO15924!("Copt"),                   
    
    /**
        Cypro Minoan
    */
    Cypro_Minoan =                         ISO15924!("Cpmn"),
    
    /**
        Cypriot
    */
    Cypriot =                              ISO15924!("Cprt"),
    
    /**
        Cyrillic
    */
    Cyrillic =                             ISO15924!("Cyrl"),
    
    /**
        Devanagari
    */
    Devanagari =                           ISO15924!("Deva"),
    
    /**
        Dives Akuru
    */
    Dives_Akuru =                          ISO15924!("Diak"),
    
    /**
        Dogra
    */
    Dogra =                                ISO15924!("Dogr"),
    
    /**
        Deseret
    */
    Deseret =                              ISO15924!("Dsrt"),
    
    /**
        Duployan
    */
    Duployan =                             ISO15924!("Dupl"),
    
    /**
        Egyptian Hieroglyphs
    */
    Egyptian_Hieroglyphs =                 ISO15924!("Egyp"),
    
    /**
        Elbasan
    */
    Elbasan =                              ISO15924!("Elba"),
    
    /**
        Elymaic
    */
    Elymaic =                              ISO15924!("Elym"),
    
    /**
        Ethiopic
    */
    Ethiopic =                             ISO15924!("Ethi"),
    
    /**
        Garay
    */
    Garay =                                ISO15924!("Gara"),
    
    /**
        Georgian
    */
    Georgian =                             ISO15924!("Geor"),
    
    /**
        Glagolitic
    */
    Glagolitic =                           ISO15924!("Glag"),
    
    /**
        Gunjala Gondi
    */
    Gunjala_Gondi =                        ISO15924!("Gong"),
    
    /**
        Masaram Gondi
    */
    Masaram_Gondi =                        ISO15924!("Gonm"),
    
    /**
        Gothic
    */
    Gothic =                               ISO15924!("Goth"),
    
    /**
        Grantha
    */
    Grantha =                              ISO15924!("Gran"),
    
    /**
        Greek
    */
    Greek =                                ISO15924!("Grek"),
    
    /**
        Gujarati
    */
    Gujarati =                             ISO15924!("Gujr"),
    
    /**
        Gurung Khema
    */
    Gurung_Khema =                         ISO15924!("Gukh"),
    
    /**
        Gurmukhi
    */
    Gurmukhi =                             ISO15924!("Guru"),
    
    /**
        Hangul
    */
    Hangul =                               ISO15924!("Hang"),
    
    /**
        Han
    */
    Han =                                  ISO15924!("Hani"),
    
    /**
        Hanunoo
    */
    Hanunoo =                              ISO15924!("Hano"),
    
    /**
        Hatran
    */
    Hatran =                               ISO15924!("Hatr"),
    
    /**
        Hebrew
    */
    Hebrew =                               ISO15924!("Hebr"),
    
    /**
        Hiragana
    */
    Hiragana =                             ISO15924!("Hira"),
    
    /**
        Anatolian Hieroglyphs
    */
    Anatolian_Hieroglyphs =                ISO15924!("Hluw"),
    
    /**
        Pahawh Hmong
    */
    Pahawh_Hmong =                         ISO15924!("Hmng"),
    
    /**
        Nyiakeng Puachue Hmong
    */
    Nyiakeng_Puachue_Hmong =               ISO15924!("Hmnp"),
    
    /**
        Katakana Or Hiragana
    */
    Katakana_Or_Hiragana =                 ISO15924!("Hrkt"),
    
    /**
        Old Hungarian
    */
    Old_Hungarian =                        ISO15924!("Hung"),
    
    /**
        Old Italic
    */
    Old_Italic =                           ISO15924!("Ital"),
    
    /**
        Javanese
    */
    Javanese =                             ISO15924!("Java"),
    
    /**
        Kayah Li
    */
    Kayah_Li =                             ISO15924!("Kali"),
    
    /**
        Katakana
    */
    Katakana =                             ISO15924!("Kana"),
    
    /**
        Kawi
    */
    Kawi =                                 ISO15924!("Kawi"),
    
    /**
        Kharoshthi
    */
    Kharoshthi =                           ISO15924!("Khar"),
    
    /**
        Khmer
    */
    Khmer =                                ISO15924!("Khmr"),
    
    /**
        Khojki
    */
    Khojki =                               ISO15924!("Khoj"),
    
    /**
        Khitan Small Script
    */
    Khitan_Small_Script =                  ISO15924!("Kits"),
    
    /**
        Kannada
    */
    Kannada =                              ISO15924!("Knda"),
    
    /**
        Kirat Rai
    */
    Kirat_Rai =                            ISO15924!("Krai"),
    
    /**
        Kaithi
    */
    Kaithi =                               ISO15924!("Kthi"),
    
    /**
        Tai Tham
    */
    Tai_Tham =                             ISO15924!("Lana"),
    
    /**
        Lao
    */
    Lao =                                  ISO15924!("Laoo"),
    
    /**
        Latin
    */
    Latin =                                ISO15924!("Latn"),
    
    /**
        Lepcha
    */
    Lepcha =                               ISO15924!("Lepc"),
    
    /**
        Limbu
    */
    Limbu =                                ISO15924!("Limb"),
    
    /**
        Linear A
    */
    Linear_A =                             ISO15924!("Lina"),
    
    /**
        Linear B
    */
    Linear_B =                             ISO15924!("Linb"),
    
    /**
        Lisu
    */
    Lisu =                                 ISO15924!("Lisu"),
    
    /**
        Lycian
    */
    Lycian =                               ISO15924!("Lyci"),
    
    /**
        Lydian
    */
    Lydian =                               ISO15924!("Lydi"),
    
    /**
        Mahajani
    */
    Mahajani =                             ISO15924!("Mahj"),
    
    /**
        Makasar
    */
    Makasar =                              ISO15924!("Maka"),
    
    /**
        Mandaic
    */
    Mandaic =                              ISO15924!("Mand"),
    
    /**
        Manichaean
    */
    Manichaean =                           ISO15924!("Mani"),
    
    /**
        Marchen
    */
    Marchen =                              ISO15924!("Marc"),
    
    /**
        Medefaidrin
    */
    Medefaidrin =                          ISO15924!("Medf"),
    
    /**
        Mende Kikakui
    */
    Mende_Kikakui =                        ISO15924!("Mend"),
    
    /**
        Meroitic Cursive
    */
    Meroitic_Cursive =                     ISO15924!("Merc"),
    
    /**
        Meroitic Hieroglyphs
    */
    Meroitic_Hieroglyphs =                 ISO15924!("Mero"),
    
    /**
        Malayalam
    */
    Malayalam =                            ISO15924!("Mlym"),
    
    /**
        Modi
    */
    Modi =                                 ISO15924!("Modi"),
    
    /**
        Mongolian
    */
    Mongolian =                            ISO15924!("Mong"),
    
    /**
        Mro
    */
    Mro =                                  ISO15924!("Mroo"),
    
    /**
        Meetei Mayek
    */
    Meetei_Mayek =                         ISO15924!("Mtei"),
    
    /**
        Multani
    */
    Multani =                              ISO15924!("Mult"),
    
    /**
        Myanmar
    */
    Myanmar =                              ISO15924!("Mymr"),
    
    /**
        Nag Mundari
    */
    Nag_Mundari =                          ISO15924!("Nagm"),
    
    /**
        Nandinagari
    */
    Nandinagari =                          ISO15924!("Nand"),
    
    /**
        Old North Arabian
    */
    Old_North_Arabian =                    ISO15924!("Narb"),
    
    /**
        Nabataean
    */
    Nabataean =                            ISO15924!("Nbat"),
    
    /**
        Newa
    */
    Newa =                                 ISO15924!("Newa"),
    
    /**
        Nko
    */
    Nko =                                  ISO15924!("Nkoo"),
    
    /**
        Nushu
    */
    Nushu =                                ISO15924!("Nshu"),
    
    /**
        Ogham
    */
    Ogham =                                ISO15924!("Ogam"),
    
    /**
        Ol Chiki
    */
    Ol_Chiki =                             ISO15924!("Olck"),
    
    /**
        Ol Onal
    */
    Ol_Onal =                              ISO15924!("Onao"),
    
    /**
        Old Turkic
    */
    Old_Turkic =                           ISO15924!("Orkh"),
    
    /**
        Oriya
    */
    Oriya =                                ISO15924!("Orya"),
    
    /**
        Osage
    */
    Osage =                                ISO15924!("Osge"),
    
    /**
        Osmanya
    */
    Osmanya =                              ISO15924!("Osma"),
    
    /**
        Old Uyghur
    */
    Old_Uyghur =                           ISO15924!("Ougr"),
    
    /**
        Palmyrene
    */
    Palmyrene =                            ISO15924!("Palm"),
    
    /**
        Pau Cin Hau
    */
    Pau_Cin_Hau =                          ISO15924!("Pauc"),
    
    /**
        Old Permic
    */
    Old_Permic =                           ISO15924!("Perm"),
    
    /**
        Phags Pa
    */
    Phags_Pa =                             ISO15924!("Phag"),
    
    /**
        Inscriptional Pahlavi
    */
    Inscriptional_Pahlavi =                ISO15924!("Phli"),
    
    /**
        Psalter Pahlavi
    */
    Psalter_Pahlavi =                      ISO15924!("Phlp"),
    
    /**
        Phoenician
    */
    Phoenician =                           ISO15924!("Phnx"),
    
    /**
        Miao
    */
    Miao =                                 ISO15924!("Plrd"),
    
    /**
        Inscriptional Parthian
    */
    Inscriptional_Parthian =               ISO15924!("Prti"),
    
    /**
        Rejang
    */
    Rejang =                               ISO15924!("Rjng"),
    
    /**
        Hanifi Rohingya
    */
    Hanifi_Rohingya =                      ISO15924!("Rohg"),
    
    /**
        Runic
    */
    Runic =                                ISO15924!("Runr"),
    
    /**
        Samaritan
    */
    Samaritan =                            ISO15924!("Samr"),
    
    /**
        Old South Arabian
    */
    Old_South_Arabian =                    ISO15924!("Sarb"),
    
    /**
        Saurashtra
    */
    Saurashtra =                           ISO15924!("Saur"),
    
    /**
        SignWriting
    */
    SignWriting =                          ISO15924!("Sgnw"),
    
    /**
        Shavian
    */
    Shavian =                              ISO15924!("Shaw"),
    
    /**
        Sharada
    */
    Sharada =                              ISO15924!("Shrd"),
    
    /**
        Siddham
    */
    Siddham =                              ISO15924!("Sidd"),
    
    /**
        Khudawadi
    */
    Khudawadi =                            ISO15924!("Sind"),
    
    /**
        Sinhala
    */
    Sinhala =                              ISO15924!("Sinh"),
    
    /**
        Sogdian
    */
    Sogdian =                              ISO15924!("Sogd"),
    
    /**
        Old Sogdian
    */
    Old_Sogdian =                          ISO15924!("Sogo"),
    
    /**
        Sora Sompeng
    */
    Sora_Sompeng =                         ISO15924!("Sora"),
    
    /**
        Soyombo
    */
    Soyombo =                              ISO15924!("Soyo"),
    
    /**
        Sundanese
    */
    Sundanese =                            ISO15924!("Sund"),
    
    /**
        Sunuwar
    */
    Sunuwar =                              ISO15924!("Sunu"),
    
    /**
        Syloti Nagri
    */
    Syloti_Nagri =                         ISO15924!("Sylo"),
    
    /**
        Syriac
    */
    Syriac =                               ISO15924!("Syrc"),
    
    /**
        Tagbanwa
    */
    Tagbanwa =                             ISO15924!("Tagb"),
    
    /**
        Takri
    */
    Takri =                                ISO15924!("Takr"),
    
    /**
        Tai Le
    */
    Tai_Le =                               ISO15924!("Tale"),
    
    /**
        New Tai Lue
    */
    New_Tai_Lue =                          ISO15924!("Talu"),
    
    /**
        Tamil
    */
    Tamil =                                ISO15924!("Taml"),
    
    /**
        Tangut
    */
    Tangut =                               ISO15924!("Tang"),
    
    /**
        Tai Viet
    */
    Tai_Viet =                             ISO15924!("Tavt"),
    
    /**
        Telugu
    */
    Telugu =                               ISO15924!("Telu"),
    
    /**
        Tifinagh
    */
    Tifinagh =                             ISO15924!("Tfng"),
    
    /**
        Tagalog
    */
    Tagalog =                              ISO15924!("Tglg"),
    
    /**
        Thaana
    */
    Thaana =                               ISO15924!("Thaa"),
    
    /**
        Thai
    */
    Thai =                                 ISO15924!("Thai"),
    
    /**
        Tibetan
    */
    Tibetan =                              ISO15924!("Tibt"),
    
    /**
        Tirhuta
    */
    Tirhuta =                              ISO15924!("Tirh"),
    
    /**
        Tangsa
    */
    Tangsa =                               ISO15924!("Tnsa"),
    
    /**
        Todhri
    */
    Todhri =                               ISO15924!("Todr"),
    
    /**
        Toto
    */
    Toto =                                 ISO15924!("Toto"),
    
    /**
        Tulu Tigalari
    */
    Tulu_Tigalari =                        ISO15924!("Tutg"),
    
    /**
        Ugaritic
    */
    Ugaritic =                             ISO15924!("Ugar"),
    
    /**
        Vai
    */
    Vai =                                  ISO15924!("Vaii"),
    
    /**
        Vithkuqi
    */
    Vithkuqi =                             ISO15924!("Vith"),
    
    /**
        Warang Citi
    */
    Warang_Citi =                          ISO15924!("Wara"),
    
    /**
        Wancho
    */
    Wancho =                               ISO15924!("Wcho"),
    
    /**
        Old Persian
    */
    Old_Persian =                          ISO15924!("Xpeo"),
    
    /**
        Cuneiform
    */
    Cuneiform =                            ISO15924!("Xsux"),
    
    /**
        Yezidi
    */
    Yezidi =                               ISO15924!("Yezi"),
    
    /**
        Yi
    */
    Yi =                                   ISO15924!("Yiii"),
    
    /**
        Zanabazar Square
    */
    Zanabazar_Square =                     ISO15924!("Zanb"),
    
    /**
        Inherited
    */
    Inherited =                            ISO15924!("Zinh"),                      
    
    /**
        Common
    */
    Common =                               ISO15924!("Zyyy"),
    
    /**
        Unknown
    */
    Unknown =                              ISO15924!("Zzzz"),
}
