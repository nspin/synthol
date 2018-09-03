with import ./nix {};

stdenvNothing.mkDerivation {
  name = "env";
  hardeningDisable = [ "all" ];
  buildInputs = [
    xen
  ];
  inherit xen;
}
