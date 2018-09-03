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

srcdir = .
prefix = /usr/local/synthol
libdir = $(prefix)/lib
incdir = $(prefix)/include

build_dir = build
build_obj = $(build_dir)/obj
build_lib = $(build_dir)/lib
build_inc = $(build_dir)/inc

src_dirs  = $(addprefix $(srcdir)/, musl/src/* compiler-rt/builtins src crt)
base_srcs = $(sort $(wildcard $(addsuffix /*.c, $(src_dirs))))
arch_srcs = $(sort $(wildcard $(addsuffix /$(ARCH)/*.[csS], $(src_dirs))))
all_objs  = $(sort $(patsubst $(srcdir)/%, $(build_obj)/%.o, $(basename $(base_srcs) $(arch_srcs))))
lib_objs  = $(filter-out $(build_obj)/crt/%, $(all_objs))
crt_objs  = $(filter $(build_obj)/crt/%, $(all_objs))

real_lib_prefixes = c
fake_lib_prefixes = m gcc gcc_s
real_lib_names    = $(real_lib_prefixes:%=lib%.a)
fake_lib_names    = $(fake_lib_prefixes:%=lib%.a)
crt_lib_names     = $(notdir $(crt_objs))
all_lib_names     = $(real_lib_names) $(fake_lib_names) $(crt_lib_names) crtbeginT.o kernel.lds
all_libs          = $(addprefix $(build_lib)/, $(all_lib_names))

musl_gen_hdrs_ext = $(build_obj)/musl/include/bits/alltypes.h $(build_obj)/musl/include/bits/syscall.h
musl_gen_hdrs_int = $(build_obj)/musl/src/internal/version.h
musl_impl_hdrs    = $(addprefix $(srcdir)/src/internal/, stdio_impl.h pthread_impl.h locale_impl.h libc.h)
src_hdrs          = $(wildcard $(addsuffix *.h, $(src_dirs)))

musl_inc_hdrs        = $(wildcard $(patsubst %, $(srcdir)/musl/include/%.h, * */* */*/*))
musl_arch_inc_hdrs   = $(wildcard $(patsubst %, $(srcdir)/musl/arch/$(ARCH)/%.h, * */* */*/*))
musl_hcra_inc_hdrs   = $(wildcard $(patsubst %, $(srcdir)/musl/arch/generic/%.h, * */* */*/*))
synth_inc_hdrs       = $(wildcard $(patsubst %, $(srcdir)/include/%.h, * */* */*/*))
synth_arch_incs_hdrs = $(wildcard $(patsubst %, $(srcdir)/arch/$(ARCH)/%.h, * */* */*/*))
all_inc_hdrs         = $(sort $(musl_inc_hdrs) $(musl_arch_inc_hdrs) $(musl_hcra_inc_hdrs) $(musl_gen_hdrs_ext) \
                              $(synth_inc_hdrs) $(synth_arch_incs_hdrs) )

all_hdrs             = $(sort $(all_inc_hdrs) $(musl_gen_hdrs_int) $(src_hdrs))
volatile_hdrs        = $(all_hdrs) # TODO(nspin)

all_inc_names = $(sort \
	$(musl_inc_hdrs:$(srcdir)/musl/include/%=%) \
	$(musl_arch_inc_hdrs:$(srcdir)/musl/arch/$(ARCH)/%=%) \
	$(musl_hcra_inc_hdrs:$(srcdir)/musl/arch/generic/%=%) \
	$(synth_inc_hdrs:$(srcdir)/include/%=%) \
	$(synth_arch_incs_hdrs:$(srcdir)/arch/$(ARCH)/%=%) \
	bits/alltypes.h bits/syscall.h )

all_incs = $(addprefix $(build_inc)/, $(all_inc_names))

install_lib = $(addprefix $(DESTDIR)$(libdir)/, $(all_lib_names))
install_inc = $(addprefix $(DESTDIR)$(incdir)/, $(all_inc_names))

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
CFLAGS_ALL += -I$(build_obj)/musl/src/internal -I$(srcdir)/musl/src/internal -I$(build_obj)/musl/include -I$(srcdir)/musl/include
CFLAGS_ALL += -I$(srcdir)/include -I$(srcdir)/arch/$(ARCH)
CFLAGS_ALL += $(CPPFLAGS) $(CFLAGS_AUTO) $(CFLAGS)

LDFLAGS_ALL = $(LDFLAGS_AUTO) $(LDFLAGS)

AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib
INSTALL = install


-include config.mk

ifeq ($(ARCH),)

all:
	@echo "Please set ARCH in config.mk before running make."
	@exit 1

else

# wat = $(all_incs)
# $(info $(wat))
# $(error " ")

all: $(all_libs) $(all_incs)

all_build = $(all_libs) $(all_incs) $(all_objs) $(musl_gen_hdrs_ext) $(musl_gen_hdrs_int)
build_dirs = $(sort $(dir $(all_build)))
$(all_build): | $(build_dirs)

$(build_dirs):
	mkdir -p $@

$(build_obj)/musl/include/bits/alltypes.h: $(srcdir)/musl/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/musl/include/alltypes.h.in $(srcdir)/musl/tools/mkalltypes.sed
	sed -f $(srcdir)/musl/tools/mkalltypes.sed $(srcdir)/musl/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/musl/include/alltypes.h.in > $@

$(build_obj)/musl/include/bits/syscall.h: $(srcdir)/musl/arch/$(ARCH)/bits/syscall.h.in
	cp $< $@
	sed -n -e s/__NR_/SYS_/p < $< >> $@

$(build_obj)/musl/src/internal/version.h: $(wildcard $(srcdir)/VERSION $(srcdir)/.git)
	printf '#define VERSION "%s"\n' "$$(cat $(srcdir)/musl/VERSION)" > $@

$(build_obj)/src/internal/version.o: $(build_obj)/src/internal/version.h

MEMOPS_SRCS = src/string/memcpy.c src/string/memmove.c src/string/memcmp.c src/string/memset.c
$(MEMOPS_SRCS:%.c=$(build_obj)/%.o): CFLAGS_ALL += $(CFLAGS_MEMOPS)

NOSSP_SRCS = $(wildcard crt/*.c) \
	musl/src/env/__libc_start_main.c musl/src/env/__init_tls.c \
	musl/src/env/__stack_chk_fail.c \
	musl/src/thread/__set_thread_area.c musl/src/thread/$(ARCH)/__set_thread_area.c \
	musl/src/string/memset.c musl/src/string/$(ARCH)/memset.c \
	musl/src/string/memcpy.c musl/src/string/$(ARCH)/memcpy.c \
$(NOSSP_SRCS:%.c=$(build_obj)/%.o): CFLAGS_ALL += $(CFLAGS_NOSSP)

CC_CMD = $(CC) $(CFLAGS_ALL) -c -o $@ $<

# Choose invocation of assembler to be used
ifeq ($(ADD_CFI),yes)
	AS_CMD = LC_ALL=C awk -f $(srcdir)/musl/tools/add-cfi.common.awk -f $(srcdir)/musl/tools/add-cfi.$(ARCH).awk $< | $(CC) $(CFLAGS_ALL) -x assembler -c -o $@ -
else
	AS_CMD = $(CC_CMD)
endif

$(build_obj)/%.o: $(srcdir)/%.s $(volatile_hdrs)
	$(AS_CMD)

$(build_obj)/%.o: $(srcdir)/%.S $(volatile_hdrs)
	$(CC_CMD)

$(build_obj)/%.o: $(srcdir)/%.c $(volatile_hdrs)
	$(CC_CMD)

$(build_lib)/libc.a: $(lib_objs)
	rm -f $@
	$(AR) rc $@ $(lib_objs)
	$(RANLIB) $@

$(addprefix $(build_lib)/, $(fake_lib_names)):
	rm -f $@
	$(AR) rc $@

$(build_lib)/%.o: $(build_obj)/crt/%.o
	cp $< $@

$(build_lib)/%.o: $(build_obj)/crt/$(ARCH)/%.o
	cp $< $@

$(build_lib)/crtbeginT.o:
	ln -s crtbegin.o $@

$(build_lib)/kernel.lds: $(srcdir)/crt/$(ARCH)/kernel.lds
	cp $< $@

$(build_inc)/%: $(srcdir)/include/%
	cp $< $@

$(build_inc)/%: $(srcdir)/musl/include/%
	cp $< $@

$(build_inc)/%: $(srcdir)/musl/arch/$(ARCH)/%
	cp $< $@

$(build_inc)/bits/%: $(build_obj)/musl/include/bits/%
	cp $< $@

$(build_inc)/bits/%: $(srcdir)/musl/arch/generic/bits/%
	cp $< $@

$(build_inc)/bits/%: $(srcdir)/musl/arch/$(ARCH)/bits/%
	cp $< $@

$(DESTDIR)$(libdir)/%: $(build_lib)/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(incdir)/%: $(build_inc)/%
	$(INSTALL) -D -m 644 $< $@

install-lib: $(install_lib)

install-inc: $(install_inc)

install: install-lib install-inc

endif

clean:
	rm -rf $(build_dir)

distclean: clean
	rm -f config.mk

.PHONY: all clean distclean install install-lib install-inc
