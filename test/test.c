#include <stdint.h>
#include <synthol.h>

int synthol_main(void) {
    synthol_logf("i'm alive %s\n", "\\(@o@)/");
    uint64_t x = 0xababab;
    uint64_t *y = &x;
    uint64_t z = (uint64_t) y;
    return x + z;
}
