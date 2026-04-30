{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.macbookpro2025;
in {
  options = with lib; {
    profiles.macbookpro2025 = {
      enable = mkEnableOption ''
        Whether to enable my laptop configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Expected disk layout (matches desktop2022 style impermanence):
    # - /dev/disk/by-partlabel "EFI - NIXOS" (p6) -> /boot (vfat)
    # - /dev/disk/by-label nixos (p7)            -> /nix (ext4, persistent store/persistence root)
    profiles = {
      common.enable = true;
      workstation.enable = true;
      personalized = {
        enable = true;
        enableSoftware = true;
        # enableProblematicSoftware = true;
        enableHome = true;
      };
      preferences.enable = true;
      playground.enable = true;
    };

     networking.hostName = "macbookpro2025";

     # Using the systemd-boot EFI boot loader as it seems to be very simple
     boot.loader.systemd-boot.enable = true;

    # Make sure initrd can mount /nix early and create mount points
    boot.initrd = {
      supportedFilesystems = ["ext4" "vfat"];
      systemd.enable = true;
    };

    boot.initrd.availableKernelModules = [
      "nvme"
      "usb_storage"
      "sdhci_pci"
    ];

    fileSystems = {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["size=4G" "mode=755"];
      };

      "/home/me" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "size=4G"
          "mode=777"
        ];
        neededForBoot = true;
      };

      "/nix" = {
        device = "/dev/disk/by-uuid/388b76d7-cb0d-4aef-80ee-13898a2ea81a";
        fsType = "ext4";
        neededForBoot = true;
        options = ["X-mount.mkdir"];
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/7414-141F";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077" "X-mount.mkdir"];
      };
    };

    swapDevices = [];

    environment.automaticPersistence = {
      normal.path = "/nix/persistent";
    };

    environment.persistence."/nix/persistent" = {
      directories = [
        # Contains uuid and gid map
        "/var/lib/nixos"

        # Log files
        "/var/log"

        # Large temp that can't fit on tmpfs
        "/tmp"

        # Keep the Asahi firmware around even when using impermanence
        {
          directory = "/etc/nixos/firmware";
          mode = "0755";
        }
      ];

      users.me = lib.mkIf (config.users.users ? me) (let
        permissions = {
          user = "me";
          group = "users";
        };
      in {
        directories = [
          # Retain all of my home config for the time being
          ({directory = ".config";} // permissions)

          # Retain Claude state
          ({directory = ".claude";} // permissions)

          # Retain Codex state
          ({directory = ".codex";} // permissions)

          # Retain ssh keys for this computer
          {
            directory = ".ssh";
            mode = "0700";
          }

          # Retain bash history
          ".bash_history"

          # Retain my projects directory (for now)
          "projects"

          # Retain trusted nix settings and repl history (repl-history, trusted-settings.json)
          ({directory = ".local/share/nix";} // permissions)

          # Retain virtualenv wheel cache
          ({directory = ".local/share/virtualenv";} // permissions)

          # Retain neovim undo files
          ({directory = ".local/share/nvim";} // permissions)

          # Retain neovim state such as undo history
          ({directory = ".local/state/nvim";} // permissions)

          # Retain nix evaluation cache, registry cache etc
          ({directory = ".cache/nix";} // permissions)

          # Retain neovim cache
          ({directory = ".cache/nvim";} // permissions)

          # Retain OpenCode state
          ({directory = ".local/state/opencode";} // permissions)

          # Retain OpenCode session data
          ({directory = ".local/share/opencode";} // permissions)

          # Retain OpenCode cache
          ({directory = ".cache/opencode";} // permissions)
        ];
      });
    };

    users.users.me.hashedPasswordFile = "/nix/persistent/secrets/me-password.hash";
    users.users.me.initialHashedPassword = lib.mkForce null;

    # Use the same nixpkgs/overlay as upstream apple-silicon-support so cache hits match
    hardware.asahi.pkgs = lib.mkForce (import flake.inputs.apple-silicon-support.inputs.nixpkgs {
      inherit (pkgs) system;
      overlays = [flake.inputs.apple-silicon-support.overlays.apple-silicon-overlay];
    });

    # Use iwd instead of wpa_supplicant
    # See [nixos-apple-silicon recommendation](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md#nixos-installation)
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd.settings.General.EnableNetworkConfiguration = true;

    # Firmware extraction: expose ESP to sandboxed builds on the running system
    hardware.asahi.peripheralFirmwareDirectory = "/etc/nixos/firmware";
    nix.settings.extra-sandbox-paths = ["/etc/nixos/firmware"];

    # Start out with some basic graphical user interface that is known to work
    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "norman";
    hardware.graphics.enable = true;
    # On Asahi, keep Xorg pinned to the display-subsystem DRM node instead of
    # auto-adding the separate GPU DRM device, which can break LightDM startup.
    services.xserver.serverFlagsSection = ''
      Option "AutoAddGPU" "off"
    '';
    services.xserver.videoDrivers = ["modesetting"];
    services.xserver.deviceSection = ''
      Option "kmsdev" "/dev/dri/by-path/platform-soc:display-subsystem-card"
    '';

    # Trackpad/keyboard settings (mirror macbookpro2017 style)
    services.libinput.enable = true;
    services.libinput.touchpad.disableWhileTyping = true;

    # GUI for asking for ssh password on non-headless laptop sessions
    programs.ssh.enableAskPassword = true;
    environment.variables.SUDO_ASKPASS = config.programs.ssh.askPassword;

    # Cloud password manager
    programs._1password-gui.enable = true;

    # Pin state version explicitly
    system.stateVersion = "25.11";
    home-manager.users.me.home.stateVersion = "25.11";
  };
}
