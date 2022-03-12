{
  description = "NixOS modules to build images for different kinds of media";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = {self, ...}: {
    nixosModules = {
      isoImage = import ./nixos-modules/iso-image self;
      sdImage = import ./nixos-modules/iso-image self;
      netbootImage = import ./nixos-modules/iso-image self;
    };
  };
}
