{
  description = "WIP";

  inputs = {
    flake-help.url = "github:rehno-lindeque/flake-help";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager"; # TODO: release-22.05
    my-dev-shells.url = "path:./my-dev-shells";
    my-nixos-configurations.url = "path:./my-nixos-configurations";
    nixpkgs-shim-images.url = "github:rehno-lindeque/nixpkgs-shim-images/fc365e485d98dcc1e8f278654618b8edf3424b03"; # master branch is broken
    nixpkgs-shim-profiles.url = "path:/home/me/projects/nixpkgs-shim/nixpkgs-shim-profiles";
    nixpkgs-shim-modules.url = "path:/home/me/projects/nixpkgs-shim/nixpkgs-shim-modules";
    nixpkgs-shim.url = "path:/home/me/projects/nixpkgs-shim";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
      nixpkgs-shim-profiles.follows = "nixpkgs-shim-profiles";
      nixpkgs-shim-modules.follows = "nixpkgs-shim-modules";
    };
    nixpkgs-shim-images.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs-shim-profiles.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs-shim-modules.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    my-dev-shells,
    my-nixos-configurations,
    ...
  }: {
    inherit (my-nixos-configurations) nixosConfigurations;
    inherit (my-dev-shells) devShells;

    # see note about devShells.<system>.default in dev-shells
    inherit (my-dev-shells) devShell;
  };
}
