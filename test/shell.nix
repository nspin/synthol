with import ../nix {};

stdenvSynthol.mkDerivation {
  name = "env";
  hardeningDisable = [ "all" ];
  buildInputs = [
  ];
}
