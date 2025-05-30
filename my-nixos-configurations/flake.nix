{
  inputs = {
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    impermanence.url = "github:nix-community/impermanence";
    # nixos-hardware.url = "github:rehno-lindeque/nixos-hardware/mediatek/mt7921k";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-impermanence.url = "github:rehno-lindeque/nixos-impermanence";
    # nixpkgs-shim.url = "path:/home/me/projects/nixpkgs-shim";
    nixpkgs-stable.url = "github:nixos/nixpkgs/6aaa3618ae99d72a2bfa8de218669ad5a42ed182?branch=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-colors.url = "github:misterio77/nix-colors";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    voxinput.url =
      # "github:richiejp/VoxInput";
      # Temporarily increase the timeout to 300 seconds
      "github:rehno-lindeque/VoxInput/patch-1";

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
    nix-colors.inputs.nixpkgs-lib.follows = "nixpkgs-stable";
    vscode-server.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-utils.follows = "flake-utils";
    };
    voxinput.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = {
    self,
    circuithub-nixos-configurations,
    flake-help,
    home-manager,
    impermanence,
    nixos-impermanence,
    nixpkgs-stable,
    ...
  }: let
    inherit (nixpkgs-stable) lib;

    system = lib.genAttrs lib.platforms.all (system: system);

    mySystems = [system.x86_64-linux];

    legacyPackages = lib.genAttrs mySystems (system:
      import nixpkgs-stable {
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
        # x86_64-linux.install-helper = self.nixosConfigurations.installer.config.system.build.install-helper;
      };

    nixosModules = rec {
      common = import ./nixos-modules/profiles/common;
      fixes = import ./nixos-modules/profiles/fixes;
      personalize = import ./nixos-modules/profiles/personalize;
      playground = import ./nixos-modules/profiles/playground;
      preferences = import ./nixos-modules/profiles/preferences;
      workstation = import ./nixos-modules/profiles/workstation;
      desktop2022 = import ./nixos-modules/profiles/desktop2022;
      macbookpro2017 = import ./nixos-modules/profiles/macbookpro2017;
      nucbox2022 = import ./nixos-modules/profiles/nucbox2022;
      # installer = import ./nixos-modules/profiles/installer;
      dotool = import ./nixos-modules/dotool;
      llm = import ./nixos-modules/llm;
      mymux = import ./nixos-modules/mymux;
      whisper = import ./nixos-modules/whisper;
      default = {
        imports = [
          common
          fixes
          personalize
          playground
          preferences
          workstation
          desktop2022
          macbookpro2017
          nucbox2022
          # installer
          impermanence.nixosModules.impermanence
          nixos-impermanence.nixosModules.default
          circuithub-nixos-configurations.nixosModules.default
          home-manager.nixosModules.home-manager
          # nixpkgs-shim.nixosModules.default
          # nixpkgs-shim.inputs.nixpkgs-shim-images.nixosModules.isoImage
          # nixpkgs-shim-profiles.nixosModules.default
        ];
      };
    };

    nixosConfigurations = {
      desktop2022 = lib.nixosSystem {
        system = system.x86_64-linux;
        modules = [
          self.nixosModules.default
          # self.inputs.nixos-hardware.nixosModules.mediatek-mt7921k
          {profiles.desktop2022.enable = true;}
        ];
        specialArgs = {flake = self;};
      };
      macbookpro2017 = lib.nixosSystem {
        system = system.x86_64-linux;
        modules = [
          self.nixosModules.default
          self.inputs.nixos-hardware.nixosModules.apple-macbook-pro-11-5
          self.inputs.nixos-hardware.nixosModules.common-gpu-amd-southern-islands
          self.nixosModules.dotool
          self.nixosModules.mymux
          self.nixosModules.whisper
          {profiles.macbookpro2017.enable = true;}
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
      # installer = lib.nixosSystem {
      #   system = system.x86_64-linux;
      #   modules = [
      #     self.nixosModules.default
      #     self.nixosModules.installer
      #     {profiles.installer.enable = true;}
      #   ];
      #   specialArgs = {flake = self;};
      # };
    };

    overlays.default = final: prev: {};
  };
}
