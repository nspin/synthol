self: super: with self; {

  llvmPackagesRaw = callPackage ./llvm { };

  wrapCCWithNoGCC = { name ? "", cc, bintools, libc, extraBuildCommands ? "" }:
    callPackage ./build-support/cc-wrapper rec {
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

  stdenvNothing = stdenv.override (drv: {
    allowedRequisites = null;
    cc = wrapCCWithNoGCC {
      name = "clang-nothing";
      cc = llvmPackagesRaw.clang;
      libc = null;
      bintools = wrapBintoolsWith {
        libc = null;
        bintools = binutils-unwrapped;
      };
    };
  });

  stdenvSynthol = stdenv.override (drv: {
    allowedRequisites = null;
    cc = wrapCCWithNoGCC {
      name = "clang-synthol";
      cc = llvmPackagesRaw.clang;
      libc = synthol;
      bintools = wrapBintoolsWith {
        libc = synthol;
        bintools = binutils-unwrapped;
        extraPackages = [
          xen
        ];
        extraBuildCommands = ''
          echo '-T ${synthol}/lib/kernel.lds' >> libc_ldflags_before
        '';
      };
    };
  });

  # stdenvSynthol = stdenv.override (drv: {
  #   allowedRequisites = null;
  #   cc = wrapCCWithFoo {
  #     name = "clang-synthol";
  #     cc = llvmPackagesFoo.clang;
  #     libc = synthol;
  #     bintools = wrapBintoolsWith {
  #       libc = synthol;
  #       bintools = binutils-unwrapped;
  #     };
  #   };
  # });

}
