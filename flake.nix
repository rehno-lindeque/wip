{
  description = "WIP";

  inputs = {
    flake-help.url = "github:rehno-lindeque/flake-help";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    my-dev-shells.url = "path:./my-dev-shells";
    my-nixos-configurations.url = "path:./my-nixos-configurations";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";

    # Redirect all inputs to local paths & unified pins
    # This can be inspected with `nix flake metadata | grep git`
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-help.follows = "flake-help";
    };
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    my-dev-shells.inputs = {
      nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
    my-nixos-configurations.inputs = {
      flake-help.follows = "flake-help";
      home-manager.follows = "home-manager";
      nixpkgs-stable.follows = "nixpkgs-stable";
      nixpkgs-unstable.follows = "nixpkgs-unstable";
      circuithub-nixos-configurations.follows = "circuithub-nixos-configurations";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    my-dev-shells,
    my-nixos-configurations,
    ...
  }: {
    inherit (my-nixos-configurations) nixosConfigurations;
    inherit (my-dev-shells) devShells;

    formatter.x86_64-linux = nixpkgs-stable.legacyPackages.x86_64-linux.alejandra;
  };
}
