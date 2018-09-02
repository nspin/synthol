{ stdenv, lib, hostPlatform
, cmake, python

, llvm
, version, compiler-rt_src
}:

stdenv.mkDerivation {
  name = "compiler-rt-${version}";

  src = compiler-rt_src;

  nativeBuildInputs = [ cmake python llvm ];

  patches = lib.optional hostPlatform.isDarwin ./compiler-rt-codesign.patch;

  # NIX_CFLAGS_LINK = " -L ${gcc-unwrapped.lib}/lib -L ${musl}/lib ";
  # NIX_CFLAGS_LINK = " -L ${gcc-unwrapped.lib}/lib -L ${musl}/lib ";
  # NIX_CFLAGS_COMPILE = " -I ${musl.dev}/include ";
  # NIX_CFLAGS_COMPILE = " -fno-builtin --rtlib=crt ";
  # NIX_CFLAGS_COMPILE = " -fno-builtin -fno-rtlib-add-rpath ";

  # postPatch = ''
  #   # sed -i -e 's/project(CompilerRT [^)]*)/project(CompilerRT NONE)/' \
  #   #   $(find . -name CMakeLists.txt)
  #   echo > cmake/Modules/BuiltinTests.cmake
  # '';

  # preConfigurePatch = ''
  #   cd lib/builtins
  # '';

  cmakeFlags = [
    "-DCMAKE_C_COMPILER_WORKS=ON"
    "-DCMAKE_CXX_COMPILER_WORKS=ON"
    "-DCMAKE_ASM_COMPILER_WORKS=ON"
    "-DCOMPILER_RT_BUILD_BUILTINS=ON"
    "-DCOMPILER_RT_BUILD_SANITIZERS=OFF"
    "-DCOMPILER_RT_BUILD_XRAY=OFF"
    "-DCOMPILER_RT_BUILD_LIBFUZZER=OFF"
    "-DCOMPILER_RT_BUILD_PROFILE=OFF"
    "-DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=ON"
    # -DCMAKE_C_COMPILER=/path/to/clang
    # -DCMAKE_AR=/path/to/llvm-ar
    # -DCMAKE_NM=/path/to/llvm-nm
    # -DCMAKE_RANLIB=/path/to/llvm-ranlib
    # -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld"
    # -DCMAKE_C_COMPILER_TARGET="arm-linux-gnueabihf"
    # "-DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON"
    # -DLLVM_CONFIG_PATH=/path/to/llvm-config
    # "-DCMAKE_C_FLAGS=build-c-flags"
    # "-DTARGET_TRIPLE=${hostPlatform.config}"
  ];

  enableParallelBuilding = true;
}
