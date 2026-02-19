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
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    export FLAKE_REF="path:$repo_root/my-nixos-configurations"
    nix run .#help 2>/dev/null
  '';
}
