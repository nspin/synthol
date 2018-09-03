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

# NOTE: changes to headers other than those in $(volatile_hdrs) don't trigger rebuild

# TODO:
#	- hardening
#	- more debugging

srcdir = .
prefix = /dev/null
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

define hdrs_in
	$(wildcard $(patsubst %, $(1)/%.h, * */* */*/*))
endef

define hdrs_in_many
	$(foreach dir,$(1),$(call hdrs_in,$(dir)))
endef

define hdr_names_in
	$(patsubst $(1)/%,%,$(wildcard $(patsubst %, $(1)/%.h, * */* */*/*)))
endef

define hdr_names_in_many
	$(foreach dir,$(1),$(call hdr_names_in,$(dir)))
endef

musl_gen_hdrs_ext = $(build_obj)/musl/include/bits/alltypes.h $(build_obj)/musl/include/bits/syscall.h
musl_gen_hdrs_int = $(build_obj)/musl/src/internal/version.h
musl_impl_hdrs    = $(addprefix $(srcdir)/musl/src/internal/, stdio_impl.h pthread_impl.h locale_impl.h libc.h)

volatile_musl_hdrs = $(musl_gen_hdrs_ext) $(musl_gen_hdrs_int) $(musl_impl_hdrs)
volatile_synth_hdrs = $(call hdrs_in_many,$(src_public_inc_dirs_synth))
volatile_hdrs = $(volatile_musl_hdrs) $(volatile_synth_hdrs)

wat = $(volatile_synth_hdrs)

src_public_inc_dirs_musl = $(srcdir)/musl/include $(srcdir)/musl/arch/$(ARCH) $(srcdir)/musl/arch/generic
src_public_inc_dirs_synth = $(srcdir)/include $(srcdir)/arch/$(ARCH)
src_public_inc_dirs = $(src_public_inc_dirs_musl) $(src_public_inc_dirs_synth)

all_public_hdr_names = $(sort \
	$(call hdr_names_in_many,$(src_public_inc_dirs)) \
	bits/alltypes.h bits/syscall.h \
	)

all_incs = $(addprefix $(build_inc)/, $(all_public_hdr_names))

hdr_dirs = $(src_public_inc_dirs) \
	$(build_obj)/musl/src/internal $(srcdir)/musl/src/internal \
	$(build_obj)/musl/include

hdr_flags = $(addprefix -I, $(hdr_dirs))

install_lib = $(addprefix $(DESTDIR)$(libdir)/, $(all_lib_names))
install_inc = $(addprefix $(DESTDIR)$(incdir)/, $(all_public_hdr_names))

LDFLAGS =
LDFLAGS_AUTO =
CPPFLAGS =
CFLAGS =
CFLAGS_AUTO = -Os -pipe
CFLAGS_C99FSE = -ffreestanding -nostdinc -std=c99

CFLAGS_ALL = $(CFLAGS_C99FSE)
CFLAGS_ALL += -D_XOPEN_SOURCE=700
CFLAGS_ALL += $(hdr_flags)
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

# $(info $(wat))
# $(error "")

all: all-libs all-incs
all-libs: $(all_libs)
all-incs: $(all_incs)

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

# When the time comes, see NOSSP_SRCS in musl Makefile
CFLAGS_ALL += $(CFLAGS_NOSSP)

CC_CMD = $(CC) $(CFLAGS_ALL) -c -o $@ $<

# Choose invocation of assembler to be used
ifeq ($(ADD_CFI),yes)
	AS_CMD = LC_ALL=C awk -f $(srcdir)/musl/tools/add-cfi.common.awk -f $(srcdir)/musl/tools/add-cfi.$(ARCH).awk $< | $(CC) $(CFLAGS_ALL) -x assembler -c -o $@ -
else
	AS_CMD = $(CC_CMD)
endif

# TODO not working
# $(build_obj)/src/%.o: $(srcdir)/src/%.S $(volatile_synth_hdrs)
# $(build_obj)/src/%.o: $(srcdir)/src/%.c $(volatile_synth_hdrs)

$(build_obj)/%.o: $(srcdir)/%.s
	$(AS_CMD)

$(build_obj)/%.o: $(srcdir)/%.S $(volatile_musl_hdrs)
	$(CC_CMD)

$(build_obj)/%.o: $(srcdir)/%.c $(volatile_musl_hdrs)
	$(CC_CMD)

$(build_obj)/src/%.o: $(srcdir)/src/%.S $(volatile_musl_hdrs) $(volatile_synth_hdrs)
	$(CC_CMD)

$(build_obj)/src/%.o: $(srcdir)/src/%.c $(volatile_musl_hdrs) $(volatile_synth_hdrs)
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

$(build_inc)/%: $(srcdir)/arch/$(ARCH)/%
	cp $< $@

$(build_inc)/%: $(srcdir)/musl/include/%
	cp $< $@

$(build_inc)/%: $(srcdir)/musl/arch/generic/%
	cp $< $@

$(build_inc)/%: $(srcdir)/musl/arch/$(ARCH)/%
	cp $< $@

$(build_inc)/%: $(build_obj)/musl/include/%
	cp $< $@

install: install-lib install-inc
install-lib: $(install_lib)
install-inc: $(install_inc)

$(DESTDIR)$(libdir)/%: $(build_lib)/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(incdir)/%: $(build_inc)/%
	$(INSTALL) -D -m 644 $< $@

endif

clean:
	rm -rf $(build_dir)

distclean: clean
	rm -f config.mk

.PHONY: all clean distclean install install-lib install-inc all-libs all-incs
