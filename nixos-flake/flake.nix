{
  description = "The nixpkgs flake, but with more internal modules exposed.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixos-images.url = "path:../nixos-images";
    nixos-images.inputs.nixpkgs.follows = "nixpkgs";
    nixos-profiles.url = "path:../nixos-profiles";
    nixos-profiles.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-images,
    nixos-profiles,
    ...
  }: nixpkgs // {
    nixosModules =
      # The modules that ship with nixpkgs
      nixpkgs.nixosModules
      # Image building modules defined inside nixpkgs
      // nixos-images.nixosModules
      # Profile modules defined inside nixpkgs
      // nixos-profiles.nixosModules;
  };
}
