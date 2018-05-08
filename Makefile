#
# Makefile for musl (requires GNU make)
#
# This is how simple every makefile should be...
# No, I take that back - actually most should be less than half this size.
#
# Use config.mak to override any of the following variables.
# Do not make changes here.
#

srcdir = .
exec_prefix = /usr/local
bindir = $(exec_prefix)/bin

prefix = /usr/local/musl
includedir = $(prefix)/include
libdir = $(prefix)/lib
syslibdir = /lib

SRC_DIRS = $(addprefix $(srcdir)/,src/* crt compiler-rt/src)
BASE_GLOBS = $(addsuffix /*.c,$(SRC_DIRS))
ARCH_GLOBS = $(addsuffix /$(ARCH)/*.[csS],$(SRC_DIRS))
BASE_SRCS = $(sort $(wildcard $(BASE_GLOBS)))
ARCH_SRCS = $(sort $(wildcard $(ARCH_GLOBS)))
BASE_OBJS = $(patsubst $(srcdir)/%,%.o,$(basename $(BASE_SRCS)))
ARCH_OBJS = $(patsubst $(srcdir)/%,%.o,$(basename $(ARCH_SRCS)))
REPLACED_OBJS = $(sort $(subst /$(ARCH)/,/,$(ARCH_OBJS)))
ALL_OBJS = $(addprefix obj/, $(filter-out $(REPLACED_OBJS), $(sort $(BASE_OBJS) $(ARCH_OBJS))))

LIBC_OBJS = $(filter obj/src/%,$(ALL_OBJS)) $(filter obj/compiler-rt/src/%,$(ALL_OBJS))
CRT_OBJS = $(filter obj/crt/%,$(ALL_OBJS))

AOBJS = $(LIBC_OBJS)
GENH = obj/include/bits/alltypes.h obj/include/bits/syscall.h
GENH_INT = obj/src/internal/version.h
IMPH = $(addprefix $(srcdir)/, src/internal/stdio_impl.h src/internal/pthread_impl.h src/internal/locale_impl.h src/internal/libc.h)

LDFLAGS =
LDFLAGS_AUTO =
LIBCC =
CPPFLAGS =
CFLAGS =
CFLAGS_AUTO = -Os -pipe
CFLAGS_C99FSE = -std=c99 -ffreestanding -nostdinc 

CFLAGS_ALL = $(CFLAGS_C99FSE)
CFLAGS_ALL += -D_XOPEN_SOURCE=700 -I$(srcdir)/arch/$(ARCH) -I$(srcdir)/arch/generic -Iobj/src/internal -I$(srcdir)/src/internal -Iobj/include -I$(srcdir)/include -I$(srcdir)/bootloader/$(ARCH)
CFLAGS_ALL += $(CPPFLAGS) $(CFLAGS_AUTO) $(CFLAGS)

LDFLAGS_ALL = $(LDFLAGS_AUTO) $(LDFLAGS)

AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib
INSTALL = $(srcdir)/tools/install.sh

ARCH_INCLUDES = $(wildcard $(srcdir)/arch/$(ARCH)/bits/*.h)
GENERIC_INCLUDES = $(wildcard $(srcdir)/arch/generic/bits/*.h)
INCLUDES = $(wildcard $(srcdir)/include/*.h $(srcdir)/include/*/*.h)
ALL_INCLUDES = $(sort $(INCLUDES:$(srcdir)/%=%) $(GENH:obj/%=%) $(ARCH_INCLUDES:$(srcdir)/arch/$(ARCH)/%=include/%) $(GENERIC_INCLUDES:$(srcdir)/arch/generic/%=include/%))

EMPTY_LIB_NAMES = m rt pthread crypt util xnet resolv dl gcc_s gcc_eh gcc
EMPTY_LIBS = $(EMPTY_LIB_NAMES:%=lib/lib%.a)
CRT_LIBS = $(addprefix lib/,$(notdir $(CRT_OBJS))) lib/crtbeginT.o
BL_LIBS = $(addprefix lib/,$(notdir $(BL_OBJS)))
STATIC_LIBS = lib/libc.a
ALL_LIBS = $(CRT_LIBS) $(STATIC_LIBS) $(EMPTY_LIBS) lib/kernel.lds

-include config.mak

ifeq ($(ARCH),)

all:
	@echo "Please set ARCH in config.mak before running make."
	@exit 1

else

all: $(ALL_LIBS)

OBJ_DIRS = $(sort $(patsubst %/,%,$(dir $(ALL_LIBS) $(ALL_OBJS) $(GENH) $(GENH_INT))) obj/include)

$(ALL_LIBS) $(ALL_OBJS) $(GENH) $(GENH_INT): | $(OBJ_DIRS)

$(OBJ_DIRS):
	mkdir -p $@

obj/include/bits/alltypes.h: $(srcdir)/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/include/alltypes.h.in $(srcdir)/tools/mkalltypes.sed
	sed -f $(srcdir)/tools/mkalltypes.sed $(srcdir)/arch/$(ARCH)/bits/alltypes.h.in $(srcdir)/include/alltypes.h.in > $@

obj/include/bits/syscall.h: $(srcdir)/arch/$(ARCH)/bits/syscall.h.in
	cp $< $@
	sed -n -e s/__NR_/SYS_/p < $< >> $@

obj/src/internal/version.h: $(wildcard $(srcdir)/VERSION $(srcdir)/.git)
	printf '#define VERSION "%s"\n' "$$(cd $(srcdir); sh tools/version.sh)" > $@

obj/src/internal/version.o: obj/src/internal/version.h

obj/crt/crt1.o: $(srcdir)/arch/$(ARCH)/crt_arch.h

OPTIMIZE_SRCS = $(wildcard $(OPTIMIZE_GLOBS:%=$(srcdir)/src/%))
$(OPTIMIZE_SRCS:$(srcdir)/%.c=obj/%.o): CFLAGS += -O3

MEMOPS_SRCS = src/string/memcpy.c src/string/memmove.c src/string/memcmp.c src/string/memset.c
$(MEMOPS_SRCS:%.c=obj/%.o): CFLAGS_ALL += $(CFLAGS_MEMOPS)

NOSSP_SRCS = $(wildcard crt/*.c) \
	src/env/__libc_start_main.c src/env/__init_tls.c \
	src/env/__stack_chk_fail.c \
	src/thread/__set_thread_area.c src/thread/$(ARCH)/__set_thread_area.c \
	src/string/memset.c src/string/$(ARCH)/memset.c \
	src/string/memcpy.c src/string/$(ARCH)/memcpy.c \
$(NOSSP_SRCS:%.c=obj/%.o): CFLAGS_ALL += $(CFLAGS_NOSSP)

$(CRT_OBJS): CFLAGS_ALL += -DCRT

CC_CMD = $(CC) $(CFLAGS_ALL) -c -o $@ $<

# Choose invocation of assembler to be used
ifeq ($(ADD_CFI),yes)
	AS_CMD = LC_ALL=C awk -f $(srcdir)/tools/add-cfi.common.awk -f $(srcdir)/tools/add-cfi.$(ARCH).awk $< | $(CC) $(CFLAGS_ALL) -x assembler -c -o $@ -
else
	AS_CMD = $(CC_CMD)
endif

obj/%.o: $(srcdir)/%.s
	$(AS_CMD)

obj/%.o: $(srcdir)/%.S
	$(CC_CMD)

obj/%.o: $(srcdir)/%.c $(GENH) $(IMPH)
	$(CC_CMD)

lib/libc.a: $(AOBJS)
	rm -f $@
	$(AR) rc $@ $(AOBJS)
	$(RANLIB) $@

$(EMPTY_LIBS):
	rm -f $@
	$(AR) rc $@

lib/%.o: obj/crt/$(ARCH)/%.o
	cp $< $@

lib/%.o: obj/crt/%.o
	cp $< $@

lib/crtbeginT.o:
	rm -f $@
	ln -s crtbegin.o $@

lib/kernel.lds: $(srcdir)/crt/$(ARCH)/kernel.lds
	cp $< $@

$(DESTDIR)$(bindir)/%: obj/%
	$(INSTALL) -D $< $@

$(DESTDIR)$(libdir)/%: lib/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: $(srcdir)/arch/$(ARCH)/bits/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: $(srcdir)/arch/generic/bits/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/bits/%: obj/include/bits/%
	$(INSTALL) -D -m 644 $< $@

$(DESTDIR)$(includedir)/%: $(srcdir)/include/%
	$(INSTALL) -D -m 644 $< $@

install-libs: $(ALL_LIBS:lib/%=$(DESTDIR)$(libdir)/%)

install-headers: $(ALL_INCLUDES:include/%=$(DESTDIR)$(includedir)/%)

install: install-libs install-headers

endif

clean:
	rm -rf obj lib

distclean: clean
	rm -f config.mak

.PHONY: all clean install install-libs install-headers
