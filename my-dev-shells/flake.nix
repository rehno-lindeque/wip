{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs"; #  "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs-unstable,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs-unstable {inherit system;};
      in rec {
        devShells = rec {
          nixEnvironment = pkgs.callPackage ./dev-shells/nix-environment {};
          pythonEnvironment = pkgs.python3.pkgs.callPackage ./dev-shells/python-environment {};
          default = nixEnvironment;
        };
      }
    );
}
