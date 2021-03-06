{ lib, newScope, stdenv
, fetchurl
, cmake, python2
, libxml2, isl
}:

let

  release_version = "6.0.0";
  version = release_version; # differentiating these is important for rc's

  callPackage = newScope (self // srcs // {
    inherit stdenv cmake libxml2 python2 isl;
    inherit release_version version;
  });

  fetch = name: sha256: fetchurl {
    url = "http://releases.llvm.org/${release_version}/${name}-${version}.src.tar.xz";
    inherit sha256;
  };

  srcs = lib.mapAttrs' (name: sha256: {
    name = "${name}_src";
    value = fetch name sha256;
  }) {
    llvm = "0224xvfg6h40y5lrbnb9qaq3grmdc5rg00xq03s1wxjfbf8krx8z";
    cfe = "0cnznvfyl3hgbg8gj58pmwf0pvd2sv5k3ccbivy6q6ggv7c6szg0";
    libcxx = "1n8d0iadkk9fdpplvxkdgrgh2szc6msrx1mpdjpmilz9pn3im4vh";
    libcxxabi = "06v4dnqh6q0r3p5h2jznlgb69lg79126lzb2s0lcw1k38b2xkili";
    libunwind = "1mpicf68f30l5jyh73h9zm5glhsikv9wi1l3411dw6qrf7clwv15";
    compiler-rt = "16m7rvh3w6vq10iwkjrr1nn293djld3xm62l5zasisaprx117k6h";
    openmp = "1z1qghx6drdvnlp406q1cp3mgikxxmwymcwzaxbv18vxbw6ha3kw";
    lld = "02qfkjkjq0snmf8dw9c255xkh8dg06ndny1x470300pk7j1lm33b";
    lldb = "0m6l2ks4banfmdh7xy7l77ri85kmzavgfy81gkc4gl6wg8flrxa6";
    clang-tools-extra = "1ll9v6r29xfdiywbn9iss49ad39ah3fk91wiv0sr6k6k9i544fq5";
  };

  self = {

    # build
    llvm = callPackage ./llvm.nix {};
    clang = callPackage ./clang {};
    # lld = callPackage ./lld.nix {};
    # lldb = callPackage ./lldb.nix {};

    # # host
    # compiler-rt = callPackage ./compiler-rt.nix {
    #   stdenv = self.stdenvLameMusl;
    # };
    # libunwind = callPackage ./libunwind.nix {};
    # libcxxabi = callPackage ./libc++abi.nix {};
    # libcxx = callPackage ./libc++ {};
    # openmp = callPackage ./openmp.nix {};

  };

in self
