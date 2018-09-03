# this is a hack

-include ../src/Makefile

# $(info $(inc_flags))
# $(error " ")

test: a.out

testclean:
	rm -f a.out

a.out: test.c $(all_libs)
	clang -isystem $(build_inc) -B $(build_lib) -L $(build_lib) -Wl,-T,$(build_lib)/kernel.lds $<

.PHONY: test testclean
