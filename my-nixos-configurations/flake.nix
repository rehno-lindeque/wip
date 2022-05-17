{
  inputs = {
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-21.11";
    neovim.url = "github:neovim/neovim/1217694f21cff2953e6c56be2157365daf7078eb?dir=contrib"; # remove after neovim 0.6.2 release
    nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    gitsigns-nvim = {
      # See https://github.com/lewis6991/gitsigns.nvim/issues/506
      url = "github:lewis6991/gitsigns.nvim/4a68d2a3733f322201a624f682d1bad2228882aa";
      flake = false;
    };

    # Redirect inputs
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-utils.follows = "flake-utils";
      flake-help.follows = "flake-help";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    neovim.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-utils.follows = "flake-utils";
    };
    nixpkgs-shim.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    circuithub-nixos-configurations,
    flake-help,
    flake-utils,
    home-manager,
    nixpkgs-shim,
    ...
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
              overlays = [self.overlays.default];
            };
          }
      );
  in
    eachDefaultEnvironment (
      {
        system,
        pkgs,
      }: rec {
        apps = pkgs.callPackages ./apps {
          inherit system;
          flake = self;
          inherit (flake-help.lib) mkHelp;
        };
        devShells.default = pkgs.callPackage ./dev-shell {};
        packages.installerIso = self.nixosConfigurations.installer.config.system.build.isoImage;
      }
    )
    // {
      nixosModules = {
        common = import ./nixos-modules/profiles/common;
        personalize = import ./nixos-modules/profiles/personalize;
        playground = import ./nixos-modules/profiles/playground;
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

      overlays.default = final: prev: {};
    };
}
