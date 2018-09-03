#include <stdint.h>
#include <synthol.h>

int synthol_main(void) {
    synthol_nlogf(100, "i'm alive \\(@o@)/ %s\n", "YAY");
    uint64_t x = 0xababab;
    uint64_t *y = &x;
    uint64_t z = (uint64_t) y;
    return x + z;
}
