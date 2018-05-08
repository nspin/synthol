#!/bin/sh
clang hello.c -B sl/lib -I sl/include/ -L sl/lib/ -nostartfiles \
    -Wl,-T,sl/lib/kernel.lds,sl/lib/start.o -o hello
