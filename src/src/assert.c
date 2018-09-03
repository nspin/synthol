#include <stdlib.h>
#include <synthol/logging.h>

#define ABORT_MESSAGE_BUFFER_SIZE 4096

_Noreturn void __assert_fail(const char *expr, const char *file, int line, const char *func)
{
    synthol_nlogf(ABORT_MESSAGE_BUFFER_SIZE, "Assertion failed: %s (%s: %s: %d)\n", expr, file, func, line);
    abort();
}
