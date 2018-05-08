#!/bin/sh
clang -B sl/lib -isystem sl/include -L sl/lib \
    -Wl,-T,sl/lib/kernel.lds -o hello hello.c
