{ config, pkgs, lib, ... }:

{
  imports =
    [
      <nixos-hardware/apple/macbook-pro/11-5>
      ../macbookpro11x/configuration.nix
      ./services.nix
    ];
}
