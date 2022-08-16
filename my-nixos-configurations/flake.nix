{
  inputs = {
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    impermanence.url = "github:nix-community/impermanence";
    nixos-impermanence.url = "github:rehno-lindeque/nixos-impermanence/wip";
    nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    # nixpkgs-shim.url = "path:/home/me/projects/nixpkgs-shim";
    nixpkgs-shim-images.url = "github:rehno-lindeque/nixpkgs-shim-images/fc365e485d98dcc1e8f278654618b8edf3424b03"; # master branch is broken
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    # Redirect inputs
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-help.follows = "flake-help";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    nixos-impermanence.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      impermanence.follows = "impermanence";
    };
    nixpkgs-shim.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    circuithub-nixos-configurations,
    flake-help,
    home-manager,
    impermanence,
    nixos-impermanence,
    nixpkgs-shim,
    ...
  }: let
    inherit (nixpkgs-shim) lib;

    system = lib.genAttrs lib.platforms.all (system: system);

    mySystems = [system.x86_64-linux];

    legacyPackages = lib.genAttrs mySystems (system:
      import nixpkgs-shim.inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [self.overlays.default];
      });
  in {
    apps = lib.genAttrs mySystems (system:
      legacyPackages.${system}.callPackages ./apps {
        inherit system;
        flake = self;
        inherit (flake-help.lib) mkHelp;
      });

    devShells = lib.genAttrs mySystems (system: {
      default = legacyPackages.${system}.callPackage ./dev-shells/default {};
    });

    packages =
      lib.recursiveUpdate
      (lib.genAttrs mySystems (system: {
        wakeup-desktop2022 = legacyPackages.${system}.callPackage ./packages/wakeup-desktop2022 {};
        wakeup-nucbox2022 = legacyPackages.${system}.callPackage ./packages/wakeup-nucbox2022 {};
      }))
      {
        # TODO: Implement isoImage as a lib instead of a module. E.g. nipxkgs-shim.lib.isoImage { .... }
        # x86_64-linux.installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage; # broken in nixos-22.05
        x86_64-linux.install-helper = self.nixosConfigurations.installer.config.system.build.install-helper;
      };

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
          # installer
          impermanence.nixosModules.impermanence
          nixos-impermanence.nixosModules.default
          circuithub-nixos-configurations.nixosModules.default
          home-manager.nixosModules.home-manager
          # nixpkgs-shim.nixosModules.default
          # nixpkgs-shim.inputs.nixpkgs-shim-images.nixosModules.isoImage
          nixpkgs-shim.inputs.nixpkgs-shim-profiles.nixosModules.default
        ];
      };
    };

    nixosConfigurations = {
      desktop2022 = lib.nixosSystem {
        system = system.x86_64-linux;
        modules = [
          self.nixosModules.default
          {profiles.desktop2022.enable = true;}
        ];
        specialArgs = {flake = self;};
      };
      nucbox2022 = lib.nixosSystem {
        system = system.x86_64-linux;
        modules = [
          self.nixosModules.default
          {profiles.nucbox2022.enable = true;}
        ];
        specialArgs = {flake = self;};
      };
      installer = lib.nixosSystem {
        system = system.x86_64-linux;
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
