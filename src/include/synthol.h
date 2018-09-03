#include <synthol/logging.h>
#include <synthol/hypercalls.h>

#include <string.h>

int synthol_main(void);
void synthol_setup(start_info_t *, void *) __attribute__((noreturn));
void shutdown(int) __attribute__((noreturn));

void itoa(char *, uint64_t);

int do_hypervisor_callback(int);

#define NL HYPERCALL_console_io(CONSOLEIO_write, 1, "\n");
#define SAY(X) HYPERCALL_console_io(CONSOLEIO_write, strlen(X), X);
#define SAYU(X) itoa(buf, (uint64_t) X); SAY(buf);

extern char buf[17]; // number of hex digits in a uint64_t + NUL
