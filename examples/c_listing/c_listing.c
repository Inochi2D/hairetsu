#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include "../../out/hairetsu.h"

void main() {
        ha_try_initialize();

        // Enumerate families
        ha_collection_t* c = ha_collection_create_from_system(true);
        uint32_t fcount = ha_collection_get_family_count(c);
        ha_family_t** families = ha_collection_get_families(c);

        for(size_t i = 0; i < fcount; i++) {
                printf("Font %lu: %s\n", i, ha_family_get_name(families[i]));
        }

        ha_try_shutdown();
}