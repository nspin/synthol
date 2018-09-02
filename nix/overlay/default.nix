self: super: with self; {

  llvmPackagesFoo = callPackage ./llvm { };

  ccWrapperFunFoo = callPackage ./cc-wrapper;

  wrapCCWithFoo = { name ? "", cc, bintools, libc, extraBuildCommands ? "" }:
    ccWrapperFunFoo rec {
      nativeTools = targetPlatform == hostPlatform && stdenv.cc.nativeTools or false;
      nativeLibc = targetPlatform == hostPlatform && stdenv.cc.nativeLibc or false;
      nativePrefix = stdenv.cc.nativePrefix or "";
      noLibc = !nativeLibc && (libc == null);

      isGNU = cc.isGNU or false;
      isClang = cc.isClang or false;

      inherit name cc bintools libc extraBuildCommands;
    };

  synthol = callPackages ./synthol {
    stdenv = stdenvNothing;
  };

  halvmExtra = callPackage ../../boot {
    stdenv = stdenvNothing;
  };

  stdenvKernel = stdenv.override (drv: {
    allowedRequisites = null;
    cc = wrapCCWithFoo {
      name = "clang-synthol";
      cc = llvmPackagesFoo.clang;
      libc = synthol;
      bintools = wrapBintoolsWith {
        libc = synthol;
        bintools = binutils-unwrapped;
        extraBuildCommands = ''
          echo '-T ${halvmExtra}/kernel.lds' >> libc_ldflags_before
          echo '${halvmExtra}/start.o' >> libc_ldflags
        '';
      };
    };
  });

  stdenvSynthol = stdenv.override (drv: {
    allowedRequisites = null;
    cc = wrapCCWithFoo {
      name = "clang-synthol";
      cc = llvmPackagesFoo.clang;
      libc = synthol;
      bintools = wrapBintoolsWith {
        libc = synthol;
        bintools = binutils-unwrapped;
      };
    };
  });

  stdenvNothing = stdenv.override (drv: {
    allowedRequisites = null;
    cc = wrapCCWithFoo {
      name = "clang-nothing";
      cc = llvmPackagesFoo.clang;
      libc = null;
      bintools = wrapBintoolsWith {
        libc = null;
        bintools = binutils-unwrapped;
      };
    };
  });

}
