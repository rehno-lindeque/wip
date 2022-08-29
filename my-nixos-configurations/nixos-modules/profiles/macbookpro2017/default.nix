{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.macbookpro2017;
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
      workstation.enable = true;
      personalized = {
        enable = true;
        enableSoftware = true;
        enableProblematicSoftware = false;
        enableHome = true;
      };
      preferences.enable = true;
      playground.enable = true;
    };
    circuithubConfigurations.developerWorkstation.enable = true;

    # Using the systemd-boot EFI boot loader as it seems to be very simple
    boot.loader.systemd-boot.enable = true;

    # On this system / and /nix/store are on an encrypted LUKS device
    boot.initrd.luks.devices = {
      nixosroot.device = "/dev/disk/by-uuid/95a903c1-2a2f-44b9-90c2-cd810ea18cd4";
    };

    fileSystems = {
      "/" = {
        # Found under /dev/disk/by-label/nixosroot
        device = "/dev/disk/by-uuid/f1e38edd-d1ae-47fe-b7cb-aaaafb0f2b45";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };

    };

    swapDevices = [
      {device = "/dev/disk/by-label/nixosswap";}
    ];
    hardware = {
      opengl.enable = true;

      # Normally provided by not-detected.nix
      enableRedistributableFirmware = true;
    };

    networking.hostName = "macboopro2017";
    # Run gnome on this computer
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
  };
}
