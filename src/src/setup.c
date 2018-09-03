#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <assert.h>

#include <synthol.h>

#include <xen/xen.h>
#include <xen/sched.h>
#include <xen/platform.h>
#include <xen/tmem.h>
#include <xen/event_channel.h>
#include <xen/xsm/flask_op.h>

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

void itoa(char *p, uint64_t x)
{
    static const char* digits = "0123456789abcdef";
    p += 16;
    *p = 0;
    for (int i = 0; i < 16; i++) {
        *--p = digits[x % 16];
        x >>= 4;
    }
}

void synthol_setup(start_info_t *start_info, void *init_sp) {
    SAY("<<<<<<<<<<<"); NL;
    SAY("start_info: "); SAYU(start_info); NL;
    SAY("init_sp:    "); SAYU(init_sp); NL;
    SAY("[enter main]"); NL;
    int ret = synthol_main();

    // uint64_t x1 = 0x854903;
    // uint64_t x2 = 0x854903;
    // uint64_t x3 = 0x854903;
    // uint64_t x4 = 0x854903;
    // uint64_t x5 = 0x854903;
    // uint64_t x6 = 0x854f03;
    // uint64_t x7 = 0x854903;
    // uint64_t x8 = 0x854903;
    // uint64_t x9 = 0x854903;

    // SAYU(&x1); SAY(" contains "); SAYU(x1); NL
    // SAYU(&x2); SAY(" contains "); SAYU(x2); NL
    // SAYU(&x3); SAY(" contains "); SAYU(x3); NL
    // SAYU(&x4); SAY(" contains "); SAYU(x4); NL
    // SAYU(&x5); SAY(" contains "); SAYU(x5); NL
    // SAYU(&x6); SAY(" contains "); SAYU(x6); NL
    // SAYU(&x7); SAY(" contains "); SAYU(x7); NL
    SAY("[exit main]"); NL;
    SAY("ret = "); SAYU(ret); NL;
    SAY(">>>>>>>>>>>"); NL;
    shutdown(SHUTDOWN_poweroff);
}
