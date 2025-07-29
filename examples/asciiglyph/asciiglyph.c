#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "../../out/hairetsu.h"

char asciiC[5] = { ' ', '.', 'o', 'O', '#' };

int main(int argc, char *argv[]) {
    ha_try_initialize();

    if (argc != 3) {
        printf("asciiglyph <font file> <character>\n");
        return -1;
    }

    char c = argv[2][0];
    ha_fontfile_t* fontFile = ha_fontfile_from_file(argv[1]);
    ha_font_t* font0 = ha_fontfile_get_fonts(fontFile)[0];
    ha_face_t* face = ha_font_create_face(font0);

    uint32_t glyphId = ha_font_find_glyph(font0, (uint32_t)c);
    ha_glyph_t* glyph = ha_face_get_glyph(face, glyphId, HA_GLYPH_TYPE_OUTLINE);

    uint32_t length;
    uint32_t width;
    uint32_t height;
    uint8_t *data;
    ha_glyph_rasterize(glyph, &data, &length, &width, &height);

    printf("%c: %u %u %u\n", c, width, height, length);

    uint8_t *asciiArt = malloc(length);
    memset(asciiArt, ' ', length);
    for(size_t i = 0; i < length; i++) {
        size_t tmp = (size_t)(4*((float)data[i]/255.0f));
        asciiArt[i] = asciiC[tmp];
    }

    for(size_t y = 0; y < height; y++) {
        for(size_t x = 0; x < width; x++) {
            size_t i = (width*y)+x;
            printf("%c", asciiArt[i]);
        }
        printf("  %lu\n", y);
    }
    

    // Cleanup.
    ha_release(fontFile);
    ha_try_shutdown();
    return 0;
}