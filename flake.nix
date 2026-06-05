{
  description = "WIP";

  inputs = {
    flake-help.url = "github:rehno-lindeque/flake-help";
    my-dev-shells.url = "path:./my-dev-shells";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    circuithub-nixos-configurations.url = "git+ssh://git@github.com/circuithub/nixos-configurations.git";

    # Redirect all inputs to local paths & unified pins
    # This can be inspected with `nix flake metadata | grep git`
    circuithub-nixos-configurations.inputs = {
      nixpkgs.follows = "nixpkgs-stable";
      flake-help.follows = "flake-help";
    };
    my-dev-shells.inputs = {
      nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    my-dev-shells,
    ...
  }: {
    inherit (my-dev-shells) devShells;

    formatter.x86_64-linux = nixpkgs-stable.legacyPackages.x86_64-linux.alejandra;
  };
}
