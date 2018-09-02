#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <assert.h>


#include <synthol/hypercalls.h>
#include <synthol/logging.h>

#include <xen/xen.h>
#include <xen/sched.h>
#include <xen/platform.h>
#include <xen/tmem.h>
#include <xen/event_channel.h>
#include <xen/xsm/flask_op.h>

void synthol_main(start_info_t *, void *) __attribute__((noreturn));
void shutdown(int) __attribute__((noreturn));

struct start_info  *system_start_info      = NULL;
struct shared_info *HYPERVISOR_shared_info = NULL;

typedef struct xen_domctl xen_domctl_t;
typedef struct xen_sysctl xen_sysctl_t;

int do_hypervisor_callback (int i){ return i; }

void shutdown(int reason)
{
    sched_shutdown_t op ={ .reason = reason ? SHUTDOWN_crash : SHUTDOWN_poweroff};
    for(;;) {
        HYPERCALL_sched_op(SCHEDOP_shutdown, &op);
    }
}

char buf[17]; // number of hex digits in a uint64_t + NUL
char buf2[17]; // number of hex digits in a uint64_t + NUL
static void itoa(char *, uint64_t);

#define NL HYPERCALL_console_io(CONSOLEIO_write, 1, "\n");
#define SAY(X) HYPERCALL_console_io(CONSOLEIO_write, strlen(X), X);
#define SAYU(X) itoa(buf, (uint64_t) X); SAY(buf);

static void itoa(char *p, uint64_t x)
{
    static const char* digits = "0123456789abcdef";
    p += 16;
    *p = 0;
    for (int i = 0; i < 16; i++) {
        *--p = digits[x % 16];
        x >>= 4;
    }
}

static void itoaL(char *p, uint64_t x)
{
    static const char* digits = "0123456789abcdef";
    p += 16;
    *p = 0;
    for (int i = 0; i < 16; i++) {
        *--p = digits[x % 16];
        x >>= 4;
        SAYU(x); NL;
    }
}

void go(void) {
    SAY("GO"); NL;
    uint64_t x = 0xb000b000;
    SAYU(-1); SAY(" contians "); SAYU(x); NL
    uint64_t y = 0xb000bb00;
    SAYU(-1); SAY(" contians "); SAYU(y); NL
    // // SAYU(&x); SAY(" contians "); SAYU(x); NL
    // uint64_t *p = &x;
    uint64_t *p = (uint64_t *) 0x00000000004affd8;
    SAYU(*p); NL;
    // SAYU(*((char *) 0xdeadf000)); NL;
    // uint64_t pv = (uint64_t) p;
    // SAYU(pv); NL;
    // // itoa(buf, (uint64_t) p);
    // uint64_t y = x + 1;
    // SAYU(y); SAY(" contians "); SAYU(x); NL;
    // go();
}

void wat() {
    SAY(""); NL;
    SAY("UP"); NL;
    SAY("start_info: "); SAYU(-1); NL;
    SAY("init_sp:    "); SAYU(-1); NL;
    uint64_t dummy = 0xaaf0;
    uint64_t *x = &dummy;
    SAYU(x); SAY(" contains "); SAYU(*x); NL
    SAY("> calling go "); NL;
}


void synthol_main(start_info_t *start_info, void *init_sp) {
    SAY(""); NL;
    SAY("UP"); NL;
    SAY("start_info: "); SAYU(start_info); NL;
    SAY("init_sp:    "); SAYU(init_sp); NL;
    uint64_t dummy = 0xaaf0;
    uint64_t *x = &dummy;
    SAYU(x); SAY(" contains "); SAYU(*x); NL
    SAY("> calling go "); NL;
    // wat();
    synthol_main(start_info, init_sp);
    // while (1) {
    //     SAYU("HREER");
    //     *x = (uint64_t) x;
    //     SAYU(x); SAY(" contians "); SAYU(*x); NL
    //     x -= 1;
    // }
    // SAY("fsda"); NL;
    // while (1) {
    //     *((uint64_t *) init_sp) = (uint64_t *) init_sp;
    //     SAYU(init_sp);
    //     SAY(" ");
    //     SAYU(*((uint64_t *) init_sp));
    //     NL;
    //     init_sp += 8;
    // }
    // SAYU(754839);
    // SAY("hi");
    // SAY("sup");
     // synthol_nlogf(100, "i'm alive \\(@o@)/ %x\n", start_info); 
    /* synthol_nlogf(10, "1234567890"); */
    // synthol_logf("1234567890");
    /* while (1) { */
        /* synthol_logf(msg); */
    /* } */
    shutdown(SHUTDOWN_poweroff);
}
