{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.desktop;
in {
  options = with lib; {
    profiles.desktop = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable my basic desktop configuration profile.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      # Enable XMonad Desktop Environment
      # windowManager = {
      #   xmonad = {
      #     enable = true;
      #     # Note that xmonad-extras seems to be broken frequently, so xmonad-contrib is easier
      #     # enableContribAndExtras = true;
      #     extraPackages = haskellPackages: [
      #       haskellPackages.xmonad-contrib
      #     ];
      #   };
      # };

      desktopManager.gnome = {
        enable = true;
      };

      displayManager = {
        # Set the desktop manager to none so that it doesn't default to xterm sometimes
        # defaultSession = "none+xmonad";
        lightdm = {
          enable = true;
          # defaultUser = config.users.users.me.name;
        };
      };
    };
  };
}
