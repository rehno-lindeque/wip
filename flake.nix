{
  description = "WIP";

  inputs = {
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    my-dev-shells.url = "path:./my-dev-shells";
    my-nixos-configurations.url = "path:./my-nixos-configurations";
    nixpkgs-shim-images.url = "github:rehno-lindeque/nixpkgs-shim-images";
    nixpkgs-shim-profiles.url = "github:rehno-lindeque/nixpkgs-shim-profiles";
    nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    circuithub-nixos-profiles.url = "git+ssh://git@github.com/circuithub/nixos-profiles.git";

    # Redirect all inputs to local paths & unified pins
    # This can be inspected with `nix flake metadata | grep git`
    circuithub-nixos-profiles.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    my-dev-shells.inputs = {
      nixpkgs-unstable.follows = "nixpkgs-unstable";
      flake-utils.follows = "flake-utils";
    };
    my-nixos-configurations.inputs = {
      flake-help.follows = "flake-help";
      flake-utils.follows = "flake-utils";
      home-manager.follows = "home-manager";
      nixpkgs-shim.follows = "nixpkgs-shim";
      nixpkgs-stable.follows = "nixpkgs-stable";
      circuithub-nixos-profiles.follows = "circuithub-nixos-profiles";
    };
    nixpkgs-shim.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      nixpkgs-shim-images.follows = "nixpkgs-shim-images";
      nixpkgs-shim-profiles.follows = "nixpkgs-shim-profiles";
    };
    nixpkgs-shim-images.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
    };
    nixpkgs-shim-profiles.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    my-dev-shells,
    my-nixos-configurations,
    nixpkgs-stable,
    ...
  }: {
    inherit (my-nixos-configurations) nixosConfigurations;
    inherit (my-dev-shells) devShells;

    # see note about devShells.<system>.default in dev-shells
    inherit (my-dev-shells) devShell;
  };
}
