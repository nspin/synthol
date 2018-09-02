#include <stdio.h>
#include <string.h>
#include <stdint.h>
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

char *msg = "a message\n";

void synthol_main(start_info_t *start_info, void *init_sp) {
    HYPERCALL_console_io(CONSOLEIO_write, strlen(msg), msg);
    /* synthol_nlogf(100, "i'm alive \\(@o@)/ %x\n", start_info); */
    /* synthol_nlogf(10, "1234567890"); */
    /* synthol_logf("1234567890"); */
    /* while (1) { */
        /* synthol_logf(msg); */
    /* } */
    shutdown(SHUTDOWN_poweroff);
}
