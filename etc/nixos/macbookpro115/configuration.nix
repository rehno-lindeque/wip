{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../macbookpro11x/configuration.nix
      ./services.nix
      ./powerManagement.nix
    ];
}
