/**
    OpenType CFF Table

    Copyright:
        Copyright © 2023-2025, Kitsunebi Games
        Copyright © 2023-2025, Inochi2D Project
    
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen

    Standards: https://learn.microsoft.com/en-us/typography/opentype/spec/cff
*/
module hairetsu.ot.tables.cff;
import hairetsu.ot.tables.common;
import hairetsu.font.sfnt.reader;
import nulib.math.fixed;
import nulib.conv;

/**
    Reads a CFF Number from the stream.
*/
float readCFFNumber(FontReader reader, bool isDict) {
    ubyte tag = reader.peek(0);

    // -107..107
    if (tag >= 32 && tag <= 246)
        return (cast(float)reader.read() - 139);
    
    // 108..1131
    if (tag >= 247 && tag <= 250)
        return cast(float)((cast(float)reader.read() - 247) * 256 + cast(float)reader.read() + 108);
    
    // -1131..-108
    if (tag >= 251 && tag <= 254)
        return cast(float)(-(cast(float)reader.read() - 251) * 256 - cast(float)reader.read() - 108);
    
    // short
    if (tag == 28) {
        reader.skip(1);
        return cast(float)reader.readElementBE!short();
    }
    
    // fixed32
    if (tag == 255) {
        reader.skip(1);
        return cast(float)reader.readElementBE!fixed32();
    }
    
    // int32 and BCD are only valid in dicts.
    if (isDict) {
        // int32
        if (tag == 255) {
            reader.skip(1);
            return cast(float)reader.readElementBE!int();
        }

        // BCD Decimal
        nstring bcd = reader.readCompressedBCDString();
        if (!bcd.empty)
            return toFloat!float(bcd[]);
    }

    return float.nan;
}

/**
    Reads a compressed BCD string from the font stream.
*/
nstring readCompressedBCDString(FontReader reader) @nogc {
    if (reader.peek() == 30) {
        reader.skip(1);

        nstring bcdstr;
        ubyte c;
        outer: while(reader.read((&c)[0..1]) > 0) {

            // Load low and high bits into an array.
            // since we need to check both for values.
            // This just makes that easier.
            ubyte[2] values = [c >> 4, c & 0xF];
            foreach(value; values) {
                if (value == 0x0F)
                    break outer;

                if (value <= 9) bcdstr ~= cast(char)('0'+value);
                else if (value == 10) bcdstr ~= '.';
                else if (value == 11) bcdstr ~= 'E';
                else if (value == 12) bcdstr ~= "E-";
                else if (value == 14) bcdstr ~= '-';
            }
        }
        return bcdstr;
    }

    return nstring.init;
}