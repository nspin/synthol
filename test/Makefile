synthol_out = ../out

all: a.out

clean:
	rm -f a.out

synthol:
	$(MAKE) -C ../src

a.out: test.c synthol
	clang -B $(synthol_out)/lib -isystem $(synthol_out)/include -L $(synthol_out)/lib \
	    -Wl,-T,$(synthol_out)/lib/kernel.lds test.c

.PHONY: all clean synthol
