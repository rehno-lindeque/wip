{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.common;
in {
  options = with lib; {
    profiles.fixes = {
      enable = mkEnableOption ''
        Configuration that should hopefully be fixed or implemented directly in nixpkgs eventually.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Fix hyprland + swaylock
    # https://github.com/NixOS/nixpkgs/issues/143365
    # https://github.com/nix-community/home-manager/issues/4411
    # https://github.com/NixOS/nixpkgs/blob/127579d6f40593f9b9b461b17769c6c2793a053d/nixos/modules/programs/wayland/wayland-session.nix#L4
    security.pam.services = lib.mkIf config.programs.hyprland.enable {
      swaylock = {};
    };
  };
}
