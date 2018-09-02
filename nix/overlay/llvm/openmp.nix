{ stdenv, cmake, perl

, llvm
, version, openmp_src
}:

stdenv.mkDerivation {
  name = "openmp-${version}";

  src = openmp_src;

  nativeBuildInputs = [ cmake perl ];
  buildInputs = [ llvm ];

  enableParallelBuilding = true;
}
