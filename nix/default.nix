# { localSystem ? { config = "x86_64-unknown-linux-musl"; }
{ localSystem ? { config = "x86_64-unknown-linux-gnu"; }
, crossSystem ? null
}:

import ./nixpkgs/pkgs/top-level {
  inherit localSystem crossSystem;
  config = { };
  overlays = [ (import ./overlay) ];
  stdenvStages = import ./stdenv;
}
