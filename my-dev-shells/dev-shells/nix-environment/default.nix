{
  mkShell,
  alejandra,
  nix,
}:
mkShell {
  buildInputs = [
    # Nix
    nix
    # Nix code formatting
    alejandra
  ];
}
