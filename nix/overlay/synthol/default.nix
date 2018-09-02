{ stdenv, lib, runCommand, lndir
, xen
}:

stdenv.mkDerivation rec {
  name    = "synthol-${version}";
  version = "0.1.0.0";

  src = runCommand "${name}-src" {} ''
    mkdir -p $out
    _f() {
      ln -s $1 $out/$2
    }
    _d() {
      cp -r $1 $out/$2
    }
    _f ${../../../configure} configure
    _f ${../../../Makefile} Makefile
    _d ${../../../compiler-rt} compiler-rt
    _d ${../../../musl} musl
    _d ${../../../synthol} synthol
    _d ${../../../crt} crt
    _d ${../../../tools} tools
  '';

  buildInputs = [
    xen
  ];

  enableParallelBuilding = true;

  hardeningDisable = [ "all" ];

  # LIBCC = " ";

  preConfigure = ''
    configureFlagsArray+=("--syslibdir=$out/lib")
  '';

  configureFlags = [
    "--enable-static"
  ];

  outputs = [ "out" "dev" ];

  dontDisableStatic = true;

  NIX_DONT_SET_RPATH = true;
}
