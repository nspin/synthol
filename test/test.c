#include <stdint.h>
// #include <synthol.h>

int synthol_main(void) {

    uint64_t x = 0xababab;
    uint64_t *y = &x;
    uint64_t z = (uint64_t) y;
    return x + z;
}
