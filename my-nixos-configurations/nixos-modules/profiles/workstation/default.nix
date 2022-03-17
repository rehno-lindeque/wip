{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.workstation;
in {
  options = with lib; {
    profiles.workstation = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable my basic workstation configuration profile.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      # Don't hold onto /tmp
      cleanTmpDir = lib.mkDefault true;
    };

    environment = {
      systemPackages = with pkgs; [
        gnome.gnome-keyring
        pstree
        ripgrep
        wget
      ];
      variables = {
        # See home-manager for the user specific version of this option programs.bash.historyControl
        HISTCONTROL = "ignorespace";
      };
    };

    # A tmpfs file system comes in handy if you don't want files to touch
    # your hard drive at all.
    fileSystems."/tmp/ram" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["size=5m"];
    };

    fonts = {
      enableDefaultFonts = lib.mkDefault true;
      fonts = with pkgs; [source-code-pro];
    };

    hardware = {
      opengl = {
        enable = lib.mkDefault true;
      };

      pulseaudio = {
        enable = lib.mkDefault true;
        daemon.logLevel = "error";
        support32Bit = lib.mkDefault true;
      };

      # This is also provided by nixpkgs#nixosModules.notDetected
      enableRedistributableFirmware = lib.mkDefault true;
    };

    networking = {
      # nmtui or nmcli can be used to control network manager
      networkmanager = {
        enable = lib.mkDefault true;
      };
      firewall = {
        enable = lib.mkDefault true;
      };
    };

    nix = {
      package = pkgs.nixUnstable;

      # Don't eliminate build dependencies or derivations for live paths during garbage-collection
      # https://nixos.wiki/wiki/FAQ#How_to_keep_build-time_dependencies_around_.2F_be_able_to_rebuild_while_being_offline.3F
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
      '';

      # Helpful for supplying remote builder options, nix copy etc
      trustedUsers = ["root" "@wheel"];
    };

    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        flake.overlay
      ];
    };

    programs = {
      bash = {
        enableCompletion = lib.mkDefault true; # auto-completion in bash
        interactiveShellInit = ''
          export HISTCONTROL=ignorespace;
        '';
      };

      git = {
        enable = true;
      };

      ssh = {
        startAgent = lib.mkDefault true;
        agentTimeout = "1h";
      };
    };

    sound = {
      enable = lib.mkDefault true;
    };

    # Security
    security.lockKernelModules = lib.mkDefault true;
    security.apparmor.enable = lib.mkDefault true;
    services.openssh.enable = lib.mkDefault false;
    services.fail2ban.enable = lib.mkDefault true;
  };
}
