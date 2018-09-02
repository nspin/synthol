#!/bin/sh
PREFIX=../out
clang -B $PREFIX/lib -isystem $PREFIX/include -L $PREFIX/lib \
    -Wl,-T,$PREFIX/lib/kernel.lds -o test test.c
