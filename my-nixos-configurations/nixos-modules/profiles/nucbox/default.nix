{...}: {
  profiles = {
    # hardened.enable = true; # temporarily broken
    common.enable = true;
    workstation.enable = true;
    circuithub.developerWorkstation.enable = true;
    personalized = {
      enable = true;
      enableSoftware = true;
      enableProblematicSoftware = false;
      enableHome = true;
    };
    preferences.enable = true;
  };

  # Using the systemd-boot EFI boot loader as it seems to be very simple
  boot.loader.systemd-boot.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];

  hardware = {
    opengl.enable = true;

    # Sound output doesn't work right now, but we want it to
    pulseaudio.enable = true;

    # Normally provided by not-detected.nix
    enableRedistributableFirmware = true;
  };

  # TODO: clean up
  # hardware.pulseaudio.daemon.logLevel = "error";
  # hardware.pulseaudio.support32Bit = lib.mkDefault true;

  networking.hostName = "nucbox2022";

  # Turning off powersave for the wifi appears to improve its performance
  # Turn this on when not using a hardwired ethernet connection
  networking.networkmanager.wifi.powersave = false;

  # Don't kill the machine with too many jobs
  nix.maxJobs = 1;

  # Limit cpu use to 3 out of the 4 available
  nix.buildCores = 3;

  sound.mediaKeys.enable = true;

  # Run gnome on this computer for now. In future I may switch it to be non-graphical.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
}
