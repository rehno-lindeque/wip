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
        devShells = {
          nixEnvironment = pkgs.callPackage ./dev-shells/nix-environment {};
          pythonEnvironment = pkgs.python3.pkgs.callPackage ./dev-shells/python-environment {};
        };

        # The documentation implies that devShells.<system>.default can be used.
        # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html#flake-output-attributes
        # However, for now this appears not to be the case.
        devShell = devShells.nixEnvironment;
      }
    );
}
