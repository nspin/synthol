#include <stdint.h>
#include <xen/sched.h>
#include <synthol/hypercalls.h>

_Noreturn void abort(void)
{
    sched_shutdown_t op = { .reason = SHUTDOWN_crash };
    for(;;) {
        HYPERCALL_sched_op(SCHEDOP_shutdown, &op);
    }
}
