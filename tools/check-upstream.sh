#!/bin/sh
set -e
here="$(dirname $0)"
cd "$here"
diff -r "$here/../src/musl" $(nix-build upstream.nix -A musl_src)/musl-* | grep -v '^Only in /nix/store/'
diff -r "$here/../src/compiler-rt/builtins" $(nix-build upstream.nix -A compiler-rt_src)/compiler-rt-*/lib/builtins | grep -v '^Only in /nix/store/'
