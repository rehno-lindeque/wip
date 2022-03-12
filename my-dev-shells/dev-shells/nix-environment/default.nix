{
  mkShell,
  alejandra,
  nix_2_6,
}:
mkShell {
  buildInputs = [
    # Nix unstable
    nix_2_6
    # Nix code formatting
    alejandra
  ];
}
