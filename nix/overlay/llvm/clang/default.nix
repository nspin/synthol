{ stdenv, cmake, python
, libxml2, libedit

, llvm
, version, release_version, cfe_src
# , clang-tools-extra_src
}:

stdenv.mkDerivation {
  name = "clang-${version}";

  src = cfe_src;

  # unpackPhase = ''
  #   unpackFile ${fetch "cfe" "0cnznvfyl3hgbg8gj58pmwf0pvd2sv5k3ccbivy6q6ggv7c6szg0"}
  #   mv cfe-${version}* clang
  #   sourceRoot=$PWD/clang
  #   unpackFile ${clang-tools-extra_src}
  #   mv clang-tools-extra-* $sourceRoot/tools/extra
  # '';

  nativeBuildInputs = [ cmake python ];
  buildInputs = [ libxml2 libedit llvm ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-std=c++11"
  ];

  patches = [ ./purity.patch ];

  postPatch = ''
    sed -i -e 's/DriverArgs.hasArg(options::OPT_nostdlibinc)/true/' \
           -e 's/Args.hasArg(options::OPT_nostdlibinc)/true/' \
           lib/Driver/ToolChains/*.cpp
  '' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    sed -i -e 's/lgcc_s/lgcc_eh/' lib/Driver/ToolChains/*.cpp
  '';

  outputs = [ "out" "lib" "python" ];

  # Clang expects to find LLVMgold in its own prefix
  # Clang expects to find sanitizer libraries in its own prefix
  postInstall = ''
    ln -sv ${llvm}/lib/LLVMgold.so $out/lib
    ln -sv ${llvm}/lib/clang/${release_version}/lib $out/lib/clang/${release_version}/
    ln -sv $out/bin/clang $out/bin/cpp

    # Move libclang to 'lib' output
    moveToOutput "lib/libclang.*" "$lib"
    substituteInPlace $out/lib/cmake/clang/ClangTargets-release.cmake \
        --replace "\''${_IMPORT_PREFIX}/lib/libclang." "$lib/lib/libclang."

    mkdir -p $python/bin $python/share/clang/
    mv $out/bin/{git-clang-format,scan-view} $python/bin
    if [ -e $out/bin/set-xcode-analyzer ]; then
      mv $out/bin/set-xcode-analyzer $python/bin
    fi
    mv $out/share/clang/*.py $python/share/clang
    rm $out/bin/c-index-test
  '';

  enableParallelBuilding = true;

  passthru = {
    isClang = true;
    inherit llvm;
  };
}
