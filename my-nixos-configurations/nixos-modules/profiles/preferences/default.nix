{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.preferences;
in {
  options = with lib; {
    profiles.preferences = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable my personal nice-to-have preferences.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Keyboard layouts that I use
    environment.systemPackages = let
      norman = pkgs.writeScriptBin "norman" ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant norman
      '';
      qwerty = pkgs.writeScriptBin "qwerty" ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap us
      '';
    in [
      norman
      qwerty
    ];

    programs.neovim.viAlias = true;
    programs.git.config = {
      init.defaultBranch = "main";
      url."https://github.com/".insteadOf = [ "gh:" "github:" ];
    };

    services = {
      # Security
      gnome.gnome-keyring.enable = true; # gnome's default keyring
    };
  };
}
