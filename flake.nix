{
  description = "WIP";

  inputs = {
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    my-dev-shells.url = "path:./my-dev-shells";
    my-nixos-configurations.url = "path:./my-nixos-configurations";
    nixpkgs-shim-images.url = "github:rehno-lindeque/nixpkgs-shim-images/fc365e485d98dcc1e8f278654618b8edf3424b03"; # master branch is broken
    nixpkgs-shim.url = "github:rehno-lindeque/nixpkgs-shim";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/release-22.05";
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";

    # Redirect all inputs to local paths & unified pins
    # This can be inspected with `nix flake metadata | grep git`
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      flake-help.follows = "flake-help";
      flake-utils.follows = "flake-utils";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      nixpkgs-unstable.follows = "nixpkgs-unstable";
      circuithub-nixos-configurations.follows = "circuithub-nixos-configurations";
    };
    nixpkgs-shim.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      nixpkgs-shim-images.follows = "nixpkgs-shim-images";
    };
    nixpkgs-shim-images.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-shim,
    my-dev-shells,
    my-nixos-configurations,
    ...
  }: {
    inherit (my-nixos-configurations) nixosConfigurations;
    inherit (my-dev-shells) devShells;

    # see note about devShells.<system>.default in dev-shells
    inherit (my-dev-shells) devShell;

    formatter.x86_64-linux = nixpkgs-shim.legacyPackages.x86_64-linux.alejandra;
  };
}
