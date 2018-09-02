{ stdenv, cmake

, libcxx, llvm, libunwind
, version, libcxxabi_src
}:

stdenv.mkDerivation {
  name = "libcxxabi-${version}";

  src = libcxxabi_src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libunwind ];

  postUnpack = ''
    unpackFile ${libcxx.src}
    unpackFile ${llvm.src}
    export cmakeFlags="-DLLVM_PATH=$PWD/$(ls -d llvm-*) -DLIBCXXABI_LIBCXX_PATH=$PWD/$(ls -d libcxx-*)"
  '' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    patch -p1 -d $(ls -d libcxx-*) -i ${./libcxx-0001-musl-hacks.patch}
  '';

  installPhase = ''
    install -d -m 755 $out/include $out/lib
    install -m 644 lib/libc++abi.so.1.0 $out/lib
    install -m 644 ../include/cxxabi.h $out/include
    ln -s libc++abi.so.1.0 $out/lib/libc++abi.so
    ln -s libc++abi.so.1.0 $out/lib/libc++abi.so.1
  '';
}
