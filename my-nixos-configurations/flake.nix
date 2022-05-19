{
  inputs = {
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager"; # /release-22.05 (once released)
    # nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    nixpkgs-shim.url = "path:/home/me/projects/nixpkgs-shim";
    nixpkgs-shim-images.url = "github:rehno-lindeque/nixpkgs-shim-images/fc365e485d98dcc1e8f278654618b8edf3424b03"; # master branch is broken
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    # Redirect inputs
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      flake-utils.follows = "flake-utils";
      flake-help.follows = "flake-help";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-shim.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
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
            pkgs = import nixpkgs-shim.inputs.nixpkgs {
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
        packages = {
          # TODO: Implement isoImage as a lib instead of a module. E.g. nipxkgs-shim.lib.isoImage { .... }
          installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
          install-helper = self.nixosConfigurations.installer.config.system.build.install-helper;
        };
      }
    )
    // {
      nixosModules = rec {
        common = import ./nixos-modules/profiles/common;
        personalize = import ./nixos-modules/profiles/personalize;
        playground = import ./nixos-modules/profiles/playground;
        preferences = import ./nixos-modules/profiles/preferences;
        workstation = import ./nixos-modules/profiles/workstation;
        desktop2022 = import ./nixos-modules/profiles/desktop2022;
        nucbox2022 = import ./nixos-modules/profiles/nucbox2022;
        installer = import ./nixos-modules/profiles/installer;
        default = {
          imports = [
            common
            personalize
            playground
            preferences
            workstation
            desktop2022
            nucbox2022
            circuithub-nixos-configurations.nixosModules.default
            home-manager.nixosModules.home-manager
            nixpkgs-shim.inputs.nixpkgs-shim-profiles.nixosModules.default
          ];
        };
      };

      nixosConfigurations = let
        inherit (nixpkgs-shim.lib) nixosSystem;
      in {
        desktop2022 = nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            {profiles.desktop2022.enable = true;}
          ];
          specialArgs = {flake = self;};
        };
        nucbox2022 = nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            {profiles.nucbox2022.enable = true;}
          ];
          specialArgs = {flake = self;};
        };
        installer = nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.default
            self.nixosModules.installer
            {profiles.installer.enable = true;}
          ];
          specialArgs = {flake = self;};
        };
      };

      overlays.default = final: prev: {};
    };
}
