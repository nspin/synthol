#!/bin/sh
cd="$(dirname $0)"
diff -r overlay/build-support nixpkgs/pkgs/build-support | grep -v '^Only in nixpkgs/pkgs/build-support'
