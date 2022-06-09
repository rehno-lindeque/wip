{mkShell}:
mkShell {
  buildInputs = [
  ];

  shellHook = let
    nc = "\\e[0m"; # No Color
    white = "\\e[1;37m";
  in ''
    clear -x
    printf "${white}"
    echo "-----------------------"
    echo "My NixOS configurations"
    echo "-----------------------"
    printf "${nc}"
    echo
    nix run .#help 2>/dev/null
  '';
}
