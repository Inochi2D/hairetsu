module hairetsu.ot.tag;

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