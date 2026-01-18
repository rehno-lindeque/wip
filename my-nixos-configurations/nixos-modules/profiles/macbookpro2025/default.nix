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
    };

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
        options = ["fmask=0022" "dmask=0022" "X-mount.mkdir"];
      };
    };

    swapDevices = [];

    # Firmware managed by nix (TODO)
    hardware.asahi.peripheralFirmwareDirectory = "/etc/nixos/firmware";

    # Ignore firmware for now (TODO: replace)
    hardware.asahi.extractPeripheralFirmware = false;

    # Keep the Asahi firmware around even when using impermanence
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

        {
          directory = "/etc/nixos/firmware";
          mode = "0755";
        }
      ];

      files = [
        "/etc/passwd"
        "/etc/group"
        "/etc/shadow"
        "/etc/subuid"
        "/etc/subgid"
      ];

    };

    # Use iwd instead of wpa_supplicant
    # See [nixos-apple-silicon recommendation](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md#nixos-installation)
    networking.networkmanager.wifi.backend = "iwd";

    # Start out with some basic graphical user interface that is known to work
    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;

    # Pin state version explicitly
    system.stateVersion = "25.11";
  };
}
