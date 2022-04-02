{
  inputs = {
    circuithub-nixos-profiles.url = "git+ssh://git@github.com/circuithub/nixos-profiles.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    neovim.url = "github:neovim/neovim/1217694f21cff2953e6c56be2157365daf7078eb?dir=contrib"; # remove after neovim 0.6.2 release
    nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    nixpkgs-shim.inputs.nixpkgs.follows = "nixpkgs-stable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";

    # Redirect inputs
    neovim.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    circuithub-nixos-profiles,
    flake-help,
    flake-utils,
    home-manager,
    neovim,
    nixpkgs-shim,
    nixpkgs-stable,
  }: let
    eachDefaultEnvironment = f:
      flake-utils.lib.eachDefaultSystem
      (
        system:
          f {
            inherit system;
            pkgs = import nixpkgs-shim {
              inherit system;
              config.allowUnfree = true;
              overlays = [self.overlay];
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
        common = import ./nixos-modules/profiles/common;
        personalize = import ./nixos-modules/profiles/personalize;
        preferences = import ./nixos-modules/profiles/preferences;
        workstation = import ./nixos-modules/profiles/workstation;
        nucbox = import ./nixos-modules/profiles/nucbox;
        installer = import ./nixos-modules/profiles/installer;
      };

      nixosConfigurations = let
        inherit (nixpkgs-shim) lib;
        extraModules =
          builtins.attrValues nixpkgs-shim.nixosModules
          ++ [
            self.nixosModules.common
            self.nixosModules.personalize
            self.nixosModules.preferences
            self.nixosModules.workstation
            circuithub-nixos-profiles.nixosModules.developerWorkstation
            home-manager.nixosModules.home-manager
          ];
      in {
        nucbox = lib.nixosSystem {
          system = "x86_64-linux";
          modules = extraModules ++ [self.nixosModules.nucbox];
          specialArgs = {flake = self;};
        };
        installer = lib.nixosSystem {
          system = "x86_64-linux";
          modules = extraModules ++ [self.nixosModules.installer];
          specialArgs = {flake = self;};
        };
      };

      overlay = final: prev: {};
    };
}
