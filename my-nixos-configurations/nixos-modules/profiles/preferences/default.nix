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
          Preferences are not specific to my own user, accounts, keys, etc.
          Additionally, no services are turned on and no packages are installed.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Clear the /tmp directory when the system is rebooted
    boot.cleanTmpDir = lib.mkDefault true;

    # TODO: move (these shortcuts are not preferences)
    # # Keyboard layouts that I use
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

    # TODO: Switch to home-manager's programs.bash.historyControl
    # environment.variables.HISTCONTROL = "ignorespace";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        {
          home = {
            enableNixpkgsReleaseCheck = true;
          };
        }
      ];
    };

    nix = {
      # Helpful for supplying remote builder options, nix copy, etc
      trustedUsers = ["root" "@wheel"];
    };

    programs = {
      bash = {
        enableCompletion = true; # auto-completion in bash
        interactiveShellInit = ''
          export HISTCONTROL=ignorespace;
        '';
      };
      git.config = {
        init.defaultBranch = "main";
        url."https://github.com/".insteadOf = ["gh:" "github:"];
      };
      neovim = {
        viAlias = true;
        defaultEditor = true;
      };
      ssh = {
        startAgent = lib.mkDefault true;
        agentTimeout = "1h";
      };
    };

    services = {
      # Security
      # TODO: dont start any services in preferences profile
      # gnome.gnome-keyring.enable = true; # gnome's default keyring

      # Set the desktop manager to none so that it doesn't default to xterm sometimes
      # TODO: check if this is this still needed?
      # xserver.displayManager.defaultSession = "none+xmonad";
    };
  };
}
