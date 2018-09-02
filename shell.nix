with import ./nix {};

stdenvNothing.mkDerivation {
  name = "env";
  buildInputs = [
    xen
  ];
  inherit xen;
}
