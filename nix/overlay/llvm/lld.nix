{ stdenv, cmake
, libxml2, llvm

, version, lld_src
}:

stdenv.mkDerivation {
  name = "lld-${version}";

  src = lld_src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libxml2 llvm ];

  outputs = [ "out" "dev" ];

  enableParallelBuilding = true;

  postInstall = ''
    moveToOutput include "$dev"
    moveToOutput lib "$dev"
  '';
}
