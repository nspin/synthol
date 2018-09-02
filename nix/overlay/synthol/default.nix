{ stdenv, lib
}:

stdenv.mkDerivation rec {
  name    = "synthol-${version}";
  version = "0.1.0.0";

  src = ../../../synthol;

  enableParallelBuilding = true;

  hardeningDisable = [ "all" ];

  # LIBCC = " ";

  preConfigure = ''
    make clean
    make distclean
    configureFlagsArray+=("--syslibdir=$out/lib")
  '';

  configureFlags = [
    "--enable-static"
  ];

  outputs = [ "out" "dev" ];

  dontDisableStatic = true;

  NIX_DONT_SET_RPATH = true;
}
