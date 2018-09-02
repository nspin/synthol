{ stdenv, cmake, python2
, libffi, libxml2
, ncurses, zlib
, debugVersion ? false

, version, release_version, llvm_src
}:

stdenv.mkDerivation {
  name = "llvm-${version}";

  src = llvm_src;

  outputs = [ "out" "python" ];

  nativeBuildInputs = [ cmake python2 ];
  buildInputs = [ libxml2 libffi ];
  propagatedBuildInputs = [ ncurses zlib ];

  postPatch = ''
      # FileSystem permissions tests fail with various special bits
      substituteInPlace unittests/Support/CMakeLists.txt \
        --replace "Path.cpp" ""
      rm unittests/Support/Path.cpp
    '' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
      patch -p1 -i ${./TLI-musl.patch}
      substituteInPlace unittests/Support/CMakeLists.txt \
        --replace "add_subdirectory(DynamicLibrary)" ""
      rm unittests/Support/DynamicLibrary/DynamicLibraryTest.cpp
    '';

  # hacky fix: created binaries need to be run before installation
  preBuild = ''
    mkdir -p $out/
    ln -sv $PWD/lib $out
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=${if debugVersion then "Debug" else "Release"}"
    "-DLLVM_INSTALL_UTILS=ON"  # Needed by rustc
    "-DLLVM_BUILD_TESTS=ON"
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_HOST_TRIPLE=${stdenv.hostPlatform.config}"
    "-DLLVM_DEFAULT_TARGET_TRIPLE=${stdenv.targetPlatform.config}"
  ];

  postBuild = ''
    rm -fR $out

    paxmark m bin/{lli,llvm-rtdyld}
    paxmark m unittests/ExecutionEngine/MCJIT/MCJITTests
    paxmark m unittests/ExecutionEngine/Orc/OrcJITTests
    paxmark m unittests/Support/SupportTests
    paxmark m bin/lli-child-target
  '';

  preCheck = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib
  '';

  postInstall = ''
    mkdir -p $python/share
    mv $out/share/opt-viewer $python/share/opt-viewer
  '';

  checkTarget = "check-all";

  enableParallelBuilding = true;
}
