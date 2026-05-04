{
  description = "hs-mx";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      hsMx = pkgs.haskellPackages.callCabal2nix "hs-mx" ./. {};
    in {
      packages.default = hsMx;
      packages.hs-mx = hsMx;

      apps.default = {
        type = "app";
        program = "${hsMx}/bin/hs-mx";
      };

      devShells.default = pkgs.haskellPackages.shellFor {
        packages = _: [hsMx];
        nativeBuildInputs = with pkgs; [
          cabal-install
          haskell-language-server
        ];
      };
    });
}
