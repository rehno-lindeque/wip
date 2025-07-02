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
    profiles.macbookpro2017 = {
      enable = mkEnableOption ''
        Whether to enable my laptop configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    profiles = {
      common.enable = true;
    };

    # Using the systemd-boot EFI boot loader as it seems to be very simple
    boot.loader.systemd-boot.enable = true;

    boot.initrd.availableKernelModules = [
      "usb_storage"
      "sdhci_pci"
    ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/388b76d7-cb0d-4aef-80ee-1389a2ea81a";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/7414-141F";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    # Firmware managed by nix (TODO)
    # hardware.asahi.peripheralFirmwareDirectory = /etc/nixos/firmware;

    # Ignore firmware for now (TODO: replace)
    hardware.asahi.extractPeripheralFirmware = false;

    # Use iwd instead of wpa_supplicant
    # See [nixos-apple-silicon recommendation](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md#nixos-installation)
    networking.networkmanager.wifi.backend = "iwd";

    # Start out with some basic graphical user interface that is known to work
    services.xserver.enable = true;
    services.xserver.desktopManager.xfce.enable = true;
  };
}
