#
# Makefile for synthol (requires GNU make)
#
# Use config.mk to override any of the following variables.
# Do not make changes here.
#
# Figure 1. The idea behind this file
#
#      | . . . .
#   my |          .
# mood |           .
#      |              . . . . .
#      + -----------------------
#        complexity of Makefile

srcdir     = .
prefix     = /usr/local/synthol
includedir = $(prefix)/include
libdir     = $(prefix)/lib

src_dirs  = $(addprefix $(srcdir)/, musl/src/* compiler-rt/src synthol/src crt)
base_srcs = $(sort $(wildcard $(addsuffix /*.c, $(src_dirs))))
arch_srcs = $(sort $(wildcard $(addsuffix /$(ARCH)/*.[csS], $(src_dirs))))
all_objs  = $(sort $(patsubst $(srcdir)/%, obj/%.o, $(basename $(base_srcs) $(arch_srcs))))
lib_objs  = $(filter-out obj/crt/%, $(all_objs))
crt_objs  = $(filter obj/crt/%, $(all_objs))

nontriv_lib_prefixes = c
triv_lib_prefixes    = m gcc gcc_s
nontriv_lib_names    = $(nontriv_lib_prefixes:%=lib%.a)
triv_lib_names       = $(triv_lib_prefixes:%=lib%.a)
crt_lib_names        = $(notdir $(crt_objs))
all_lib_names        = $(nontriv_lib_names) $(triv_lib_names) $(crt_lib_names) crtbeginT.o kernel.lds
all_libs             = $(addprefix lib/, $(all_lib_names))

musl_gen_hdrs_ext = obj/musl/include/bits/alltypes.h obj/musl/include/bits/syscall.h
musl_gen_hdrs_int = obj/musl/src/internal/version.h
musl_impl_hdrs    = $(addprefix $(srcdir)/src/internal/, stdio_impl.h pthread_impl.h locale_impl.h libc.h)
src_hdrs          = $(wildcard $(addsuffix *.h, $(src_dirs)))

musl_inc_hdrs        = $(wildcard $(patsubst %, $(srcdir)/musl/include/%.h, * */* */*/*))
musl_arch_inc_hdrs   = $(wildcard $(patsubst %, $(srcdir)/musl/arch/$(ARCH)/%.h, * */* */*/*))
musl_hcra_inc_hdrs   = $(wildcard $(patsubst %, $(srcdir)/musl/arch/generic/%.h, * */* */*/*))
synth_inc_hdrs       = $(wildcard $(patsubst %, $(srcdir)/synthol/include/%.h, * */* */*/*))
synth_arch_incs_hdrs = $(wildcard $(patsubst %, $(srcdir)/synthol/arch/$(ARCH)/%.h, * */* */*/*))
all_inc_hdrs         = $(sort $(musl_inc_hdrs) $(musl_arch_inc_hdrs) $(musl_hcra_inc_hdrs) $(musl_gen_hdrs_ext) \
					          $(synth_inc_hdrs) $(synth_arch_incs_hdrs) )

all_hdrs             = $(sort $(all_inc_hdrs) $(musl_gen_hdrs_int) $(src_hdrs))
volatile_hdrs        = $(all_hdrs) # TODO(nspin)

all_include_names = $(sort \
	$(musl_inc_hdrs:$(srcdir)/musl/include/%=%) \
	$(musl_arch_inc_hdrs:$(srcdir)/musl/arch/$(ARCH)/%=%) \
	$(musl_hcra_inc_hdrs:$(srcdir)/musl/arch/generic/%=%) \
	$(synth_inc_hdrs:$(srcdir)/synthol/include/%=%) \
	$(synth_arch_incs_hdrs:$(srcdir)/synthol/arch/$(ARCH)/%=%) \
	bits/alltypes.h bits/syscall.h )

install_lib     = $(addprefix $(DESTDIR)$(libdir)/, $(all_lib_names))
install_include = $(addprefix $(DESTDIR)$(includedir)/, $(all_include_names))

LDFLAGS =
LDFLAGS_AUTO =
LIBCC =
CPPFLAGS =
CFLAGS =
CFLAGS_AUTO = -Os -pipe
CFLAGS_C99FSE = -ffreestanding -nostdinc -std=c99

CFLAGS_ALL = $(CFLAGS_C99FSE)
CFLAGS_ALL += -D_XOPEN_SOURCE=700
CFLAGS_ALL += -I$(srcdir)/musl/arch/$(ARCH) -I$(srcdir)/musl/arch/generic
CFLAGS_ALL += -Iobj/musl/src/internal -I$(srcdir)/musl/src/internal -Iobj/musl/include -I$(srcdir)/musl/include
CFLAGS_ALL += -I$(srcdir)/synthol/include -I$(srcdir)/synthol/arch/$(ARCH)
CFLAGS_ALL += $(CPPFLAGS) $(CFLAGS_AUTO) $(CFLAGS)

LDFLAGS_ALL = $(LDFLAGS_AUTO) $(LDFLAGS)

AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib
INSTALL = $(srcdir)/tools/install.sh


-include config.mk

ifeq ($(ARCH),)

all:
	@echo "Please set ARCH in config.mk before running make."
	@exit 1

else

all: $(all_libs)

obj_dirs = $(sort $(dir $(all_libs) $(all_objs) $(musl_gen_hdrs_ext) $(musl_gen_hdrs_int)))

$(all_libs) $(all_objs) $(all_libs) $(all_objs) $(musl_gen_hdrs_ext) $(musl_gen_hdrs_int): | $(obj_dirs)

$(obj_dirs):
	mkdir -p $@

obj/musl/include/bits/alltypes.h: $(srcdir)/musl/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/musl/include/alltypes.h.in $(srcdir)/tools/mkalltypes.sed
	sed -f $(srcdir)/tools/mkalltypes.sed $(srcdir)/musl/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/musl/include/alltypes.h.in > $@

obj/musl/include/bits/syscall.h: $(srcdir)/musl/arch/$(ARCH)/bits/syscall.h.in
	cp $< $@
	sed -n -e s/__NR_/SYS_/p < $< >> $@

obj/musl/src/internal/version.h: $(wildcard $(srcdir)/VERSION $(srcdir)/.git)
	printf '#define VERSION "%s"\n' "$$(cd $(srcdir)/musl; sh tools/version.sh)" > $@

obj/src/internal/version.o: obj/src/internal/version.h

OPTIMIZE_SRCS = $(wildcard $(OPTIMIZE_GLOBS:%=$(srcdir)/src/%))
$(OPTIMIZE_SRCS:$(srcdir)/%.c=obj/%.o): CFLAGS += -O3

MEMOPS_SRCS = src/string/memcpy.c src/string/memmove.c src/string/memcmp.c src/string/memset.c
$(MEMOPS_SRCS:%.c=obj/%.o): CFLAGS_ALL += $(CFLAGS_MEMOPS)

NOSSP_SRCS = $(wildcard crt/*.c) \
	musl/src/env/__libc_start_main.c musl/src/env/__init_tls.c \
	musl/src/env/__stack_chk_fail.c \
	musl/src/thread/__set_thread_area.c musl/src/thread/$(ARCH)/__set_thread_area.c \
	musl/src/string/memset.c musl/src/string/$(ARCH)/memset.c \
	musl/src/string/memcpy.c musl/src/string/$(ARCH)/memcpy.c \
$(NOSSP_SRCS:%.c=obj/%.o): CFLAGS_ALL += $(CFLAGS_NOSSP)

$(CRT_OBJS): CFLAGS_ALL += -DCRT

CC_CMD = $(CC) $(CFLAGS_ALL) -c -o $@ $<

# Choose invocation of assembler to be used
ifeq ($(ADD_CFI),yes)
	AS_CMD = LC_ALL=C awk -f $(srcdir)/tools/add-cfi.common.awk -f $(srcdir)/tools/add-cfi.$(ARCH).awk $< | $(CC) $(CFLAGS_ALL) -x assembler -c -o $@ -
else
	AS_CMD = $(CC_CMD)
endif

obj/%.o: $(srcdir)/%.s $(volatile_hdrs)
	$(AS_CMD)

obj/%.o: $(srcdir)/%.S $(volatile_hdrs)
	$(CC_CMD)

obj/%.o: $(srcdir)/%.c $(volatile_hdrs)
	$(CC_CMD)

lib/libc.a: $(lib_objs)
	rm -f $@
	$(AR) rc $@ $(lib_objs)
	$(RANLIB) $@

$(addprefix lib/, $(triv_lib_names)):
	rm -f $@
	$(AR) rc $@

$(DESTDIR)$(libdir)/%: lib/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(libdir)/%.o: obj/crt/%.o
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(libdir)/%.o: obj/crt/$(ARCH)/%.o
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(libdir)/crtbeginT.o:
	ln -s crtbegin.o $@

$(DESTDIR)$(libdir)/kernel.lds: $(srcdir)/crt/$(ARCH)/kernel.lds
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/%: $(srcdir)/synthol/include/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/%: $(srcdir)/musl/include/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/%: $(srcdir)/musl/arch/$(ARCH)/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: obj/musl/include/bits/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: $(srcdir)/musl/arch/generic/bits/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: $(srcdir)/musl/arch/$(ARCH)/bits/%
	$(INSTALL) -D -m 644 $< $@

install-lib: $(install_lib)

install-include: $(install_include)

install: install-lib install-include

endif

clean:
	rm -rf obj lib

distclean: clean
	rm -f config.mk

.PHONY: all clean distclean install install-lib install-include
