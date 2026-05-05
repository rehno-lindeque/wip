{
  description = "sesh";

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
      sesh = pkgs.haskellPackages.callCabal2nix "sesh" ./. {};
    in {
      packages.default = sesh;
      packages.sesh = sesh;

      apps.default = {
        type = "app";
        program = "${sesh}/bin/sesh";
      };

      devShells.default = pkgs.haskellPackages.shellFor {
        packages = _: [sesh];
        nativeBuildInputs = with pkgs; [
          cabal-install
          haskell-language-server
        ];
      };
    });
}
