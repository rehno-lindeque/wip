{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>

      # ...
      ../macbookpro/configuration.nix

      # Configuration for the retina screen
      ../retina/configuration.nix

       # ...
      ./boot.nix
      ./services.nix
      ./hardware.nix
    ];
}
