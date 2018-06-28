{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../macbookpro115/configuration.nix
      ./networking.nix
    ];
}
