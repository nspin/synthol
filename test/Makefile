-include ../src/Makefile

test: a.out

testclean:
	rm -f a.out

a.out: test.c $(all_libs) $(all_incs)
	clang -isystem $(build_inc) -B $(build_lib) -L $(build_lib) -Wl,-T,$(build_lib)/kernel.lds $<

.PHONY: test testclean
