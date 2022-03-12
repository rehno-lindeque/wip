{
  inputs = {
    circuithub-nixos-profiles.url = "git+ssh://git@github.com/circuithub/nixos-profiles.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    nixos.url = "path:../nixos-flake";
    nixos.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = {
    self,
    circuithub-nixos-profiles,
    flake-help,
    flake-utils,
    nixos,
    nixpkgs,
  }: let
    eachDefaultEnvironment = f:
      flake-utils.lib.eachDefaultSystem
      (
        system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );
  in
    eachDefaultEnvironment (
      {
        system,
        pkgs,
      }: rec {
        apps = import ./apps {
          inherit (flake-help.lib) mkHelp;
          inherit (pkgs) writeScript;
          inherit system;
          flake = self;
        };
        devShell = import ./dev-shell {
          inherit (pkgs) mkShell;
          inherit apps;
        };
      }
    )
    // {
      nixosModules = {
        personalized = import ./nixos-modules/profiles/personalized;
        workstation = import ./nixos-modules/profiles/workstation;
        nukbox = import ./nixos-modules/profiles/nukbox;
        installer = import ./nixos-modules/profiles/installer;
      };

      nixosConfigurations = let
        inherit (nixpkgs) lib;
        extraModules = [
          nixos.nixosModules.allHardware
          nixos.nixosModules.installationDevice
          nixos.nixosModules.base
          nixos.nixosModules.isoImage
          # nixos.nixosModules.hardened # temporarily broken
          self.nixosModules.personalized
          self.nixosModules.workstation
          circuithub-nixos-profiles.nixosModules.developerWorkstation
        ];
      in {
        # nukbox = lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = extraModules ++ [self.nixosModules.nukbox];
        #   specialArgs = {flake = self;};
        # };
        installer = lib.nixosSystem {
          system = "x86_64-linux";
          modules = extraModules ++ [self.nixosModules.installer];
          specialArgs = {flake = self;};
        };
      };

      overlay = final: prev: {};
    };
}
