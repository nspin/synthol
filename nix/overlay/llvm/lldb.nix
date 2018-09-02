{ stdenv, cmake, python, which, swig
, ncurses, zlib, libedit, libxml2

, llvm, clang
, version, lldb_src
}:

stdenv.mkDerivation {
  name = "lldb-${version}";

  src = lldb_src;

  postPatch = ''
    # Fix up various paths that assume llvm and clang are installed in the same place
    sed -i 's,".*ClangConfig.cmake","${clang}/lib/cmake/clang/ClangConfig.cmake",' \
      cmake/modules/LLDBStandalone.cmake
    sed -i 's,".*tools/clang/include","${clang}/include",' \
      cmake/modules/LLDBStandalone.cmake
    sed -i 's,"$.LLVM_LIBRARY_DIR.",${llvm}/lib ${clang}/lib,' \
      cmake/modules/LLDBStandalone.cmake
  '';

  nativeBuildInputs = [ cmake python which swig ];
  buildInputs = [ ncurses zlib libedit libxml2 llvm ];

  CXXFLAGS = "-fno-rtti";
  hardeningDisable = [ "format" ];

  cmakeFlags = [
    "-DLLDB_CODESIGN_IDENTITY=" # codesigning makes nondeterministic
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/share/man/man1
    cp ../docs/lldb.1 $out/share/man/man1/
  '';
}
