#ifndef _SYNTHOL_HYPERCALLS_H
#define _SYNTHOL_HYPERCALLS_H

#include <assert.h>
#include <stdint.h>
#include <sys/types.h>

#include <xen/xen.h>
#include <xen/platform.h>
#include <xen/tmem.h>
#include <xen/event_channel.h>
#include <xen/xsm/flask_op.h>

typedef struct xen_domctl xen_domctl_t;
typedef struct xen_sysctl xen_sysctl_t;

int HYPERCALL_set_trap_table(const struct trap_info traps[]);
int HYPERCALL_mmu_update(const struct mmu_update reqs[], unsigned count, unsigned *done_out, unsigned foreigndom);
int HYPERCALL_set_gdt(const xen_pfn_t frames[], unsigned int entries);
int HYPERCALL_stack_switch(unsigned long ss, unsigned long esp);
int HYPERCALL_set_callbacks(void *event_addr, void *fail_addr);
int HYPERCALL_fpu_taskswitch(int set);
int HYPERCALL_platform_op(const struct xen_platform_op*);
int HYPERCALL_set_debugreg(int regno, unsigned long val);
int HYPERCALL_get_debugreg(int regno);
int HYPERCALL_update_descriptor(uint64_t ma, uint64_t desc);
int HYPERCALL_memory_op(unsigned int cmd, void *arg);
int HYPERCALL_multicall(multicall_entry_t *entries, int nr_calls);
int HYPERCALL_update_va_mapping(unsigned long va, uint64_t val, unsigned long fl);
int HYPERCALL_set_timer_op(uint64_t timeout);
int HYPERCALL_xen_version(int cmd, void *buffer);
int HYPERCALL_console_io(int cmd, int count, char *buffer);
int HYPERCALL_grant_table_op(int cmd, void *args, unsigned int count);
int HYPERCALL_vm_assist(unsigned int cmd, unsigned int type);
int HYPERCALL_update_va_mapping_otherdomain(unsigned long va, uint64_t val, unsigned long fl, domid_t domid);
int HYPERCALL_iret(void);
int HYPERCALL_vcpu_op(int cmd, int vcpuid, void *extra);

#ifdef __x86_64__
int HYPERCALL_set_segment_base(unsigned int which, unsigned long base);
#endif

int HYPERCALL_mmuext_op(struct mmuext_op *op, unsigned int count, unsigned int *pdone, unsigned int foreigndom);

#ifdef XEN_FLASK_INTERFACE_VERSION
int HYPERCALL_xsm_op(xen_flask_op_t *op);
#else
int HYPERCALL_xsm_op(flask_op_t *op);
#endif

int HYPERCALL_nmi_op(int cmd, void *arg);
int HYPERCALL_sched_op(int cmd, void *arg);
int HYPERCALL_callback_op(int cmd, void *arg);
int HYPERCALL_xenoprof_op(int op, void *arg);
int HYPERCALL_event_channel_op(int cmd, void *arg);
int HYPERCALL_physdev_op(int cmd, void *arg);
int HYPERCALL_hvm_op(int op, void *arg);
int HYPERCALL_sysctl(xen_sysctl_t *op);
int HYPERCALL_domctl(xen_domctl_t *op);
int HYPERCALL_kexec_op(unsigned long op, int arg1, void *arg);
int HYPERCALL_tmem_op(tmem_op_t *ops);

#endif
