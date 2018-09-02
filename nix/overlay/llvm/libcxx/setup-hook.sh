export NIX_CXXSTDLIB_COMPILE+=" -isystem @out@/include/c++/v1"
export NIX_CXXSTDLIB_LINK=" -stdlib=libc++ -lc++abi"
