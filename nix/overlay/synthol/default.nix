{ stdenv, lib, runCommand, lndir
, xen
}:

stdenv.mkDerivation rec {
  name    = "synthol-${version}";
  version = "0.1.0.0";

  src = ../../../src;

  buildInputs = [
    xen
  ];

  enableParallelBuilding = true;

  hardeningDisable = [ "all" ];

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
