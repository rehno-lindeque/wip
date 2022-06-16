{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs"; #  "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs-unstable,
  }: let
    inherit (nixpkgs-unstable) lib legacyPackages;

    system = lib.genAttrs lib.platforms.all (system: system);

    mySystems = [system.x86_64-linux];
  in {
    devShells = lib.genAttrs mySystems (system: {
      nixEnvironment = legacyPackages.${system}.callPackage ./dev-shells/nix-environment {};
      pythonEnvironment = legacyPackages.${system}.python3.pkgs.callPackage ./dev-shells/python-environment {};
      default = self.devShells.${system}.nixEnvironment;
    });
  };
}
