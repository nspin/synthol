{ lib, stdenv, cmake, python

, libcxxabi
, version, libcxx_src
}:

stdenv.mkDerivation rec {
  name = "libcxx-${version}";

  enableParallelBuilding = true;

  src = fetch "libcxx" "1n8d0iadkk9fdpplvxkdgrgh2szc6msrx1mpdjpmilz9pn3im4vh";

  postUnpack = ''
    unpackFile ${libcxxabi.src}
    export LIBCXXABI_INCLUDE_DIR="$PWD/$(ls -d libcxxabi-${version}*)/include"
  '';

  prePatch = ''
    substituteInPlace lib/CMakeLists.txt --replace "/usr/lib/libc++" "\''${LIBCXX_LIBCXXABI_LIB_PATH}/libc++"
  '';

  patches = stdenv.lib.optional stdenv.hostPlatform.isMusl ../libcxx-0001-musl-hacks.patch;

  preConfigure =
  # ''
  #   # Get headers from the cxxabi source so we can see private headers not installed by the cxxabi package
  #   cmakeFlagsArray=($cmakeFlagsArray -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$LIBCXXABI_INCLUDE_DIR")
  # '' +
  lib.optionalString stdenv.hostPlatform.isMusl ''
    patchShebangs utils/cat_files.py
  '';

  nativeBuildInputs = [ cmake ] ++ stdenv.lib.optional stdenv.hostPlatform.isMusl python;
  buildInputs = [ libcxxabi ];

  cmakeFlags = [
    "-DLIBCXX_LIBCXXABI_LIB_PATH=${libcxxabi}/lib"
    "-DLIBCXX_LIBCPPABI_VERSION=2"
    "-DLIBCXX_CXX_ABI=libcxxabi"
  ] ++ stdenv.lib.optional stdenv.hostPlatform.isMusl "-DLIBCXX_HAS_MUSL_LIBC=1";

  setupHook = ./setup-hook.sh;
}
