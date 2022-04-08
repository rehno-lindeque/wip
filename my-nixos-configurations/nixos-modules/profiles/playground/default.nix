{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.playground;
in {
  options = with lib; {
    profiles.playground = {
      enable = mkEnableOption ''
        Whether to enable my personal playground.
        This includes services, packages, options, and other cruft that I'm
        trying out, but haven't committed to keeping longer term.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable
    (lib.mkMerge [
      (lib.mkIf config.profiles.preferences.enable {
        home-manager = {
          users.me = {pkgs, ...}: {
            programs = {
              neovim = {
                extraConfig = ''
                  luafile ${./neovim/playground.lua}
                '';
              };
            };
          };
        };
        };
      })
      })
    ]);
}
