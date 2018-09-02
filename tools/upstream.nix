with import <nixpkgs> {}; {

  musl_src = 
    let
      version = "1.1.19";
    in runCommand "musl_src" {
      src = fetchurl {
        url = "http://www.musl-libc.org/releases/musl-${version}.tar.gz";
        sha256 = "1nf1wh44bhm8gdcfr75ayib29b99vpq62zmjymrq7f96h9bshnfv";
      };
    } ''
      mkdir $out
      tar -xzf $src -C $out
    '';

  compiler-rt_src =
    let
      version = "6.0.0";
    in runCommand "compiler-rt_src" {
      src = fetchurl {
        url = "http://releases.llvm.org/${version}/compiler-rt-${version}.src.tar.xz";
        sha256 = "16m7rvh3w6vq10iwkjrr1nn293djld3xm62l5zasisaprx117k6h";
      };
    } ''
      mkdir $out
      tar -xJf $src -C $out
    '';

}
