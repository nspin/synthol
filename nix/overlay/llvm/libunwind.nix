{ stdenv, cmake, python

, llvm
, version, libunwind_src
}:

stdenv.mkDerivation {
  name = "libunwind-${version}";

  src = fetch "libunwind" "1mpicf68f30l5jyh73h9zm5glhsikv9wi1l3411dw6qrf7clwv15";

  nativeBuildInputs = [ cmake llvm ];

  enableParallelBuilding = true;
}
