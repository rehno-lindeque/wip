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
        # # Keyboard layouts that I use (TODO: there may be a better way to set this up)
        # environment.systemPackages = let
        #   norman = pkgs.writeScriptBin "norman" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant norman
        #   '';
        #   qwerty = pkgs.writeScriptBin "qwerty" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us
        #   '';
        # in [
        #   norman
        #   qwerty
        # ];

        # TODO: should this be a preference setting for e.g. some terminal?
        # TODO: check where fonts are used (vim?)
        # TODO: Check against any home-manager font settings?
        # TODO: Check against i18n.consoleFont ?
        # fonts.fonts = with pkgs; [
        #   source-code-pro
        #   terminus-nerdfont
        #   inconsolata-nerdfont
        #   firacode-nerdfont ?
        #   source-code-pro-nerdfont ?
        #   fira-code
        #   iosevka
        #   terminus_font
        # ];

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

      (lib.mkIf config.profiles.nucbox.enable {
        # Set the desktop manager to none so that it doesn't default to xterm sometimes
        # TODO: check if this is this still needed?
        # xserver.displayManager.defaultSession = "none+xmonad";

        # Security
        services.gnome.gnome-keyring.enable = true; # gnome's default keyring
      })
    ]);
}
