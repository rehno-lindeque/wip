{...}: {
  profiles = {
    # hardened.enable = true; # temporarily broken
    workstation.enable = true;
    circuithub.developerWorkstation.enable = true;
    personalized = {
      enable = true;
      includeRegular = true;
      includeProblematic = false;
    };
    preferences.enable = true;
    desktop.enable = true;
  };

  boot.loader = {
    # Use the systemd-boot EFI boot loader as it appears to be very simple
    systemd-boot.enable = true;
  };

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

  # Set the host name for this computer
  networking = {
    hostName = "nukbox2022";
    networkmanager.wifi.powersave = false; # wifi is slow and unstable without this
  };

  nix = {
    # Don't kill the machine with too many jobs
    maxJobs = 1;
    # Limit cpu use to 3 out of the 4 available
    buildCores = 3;
  };

  sound.mediaKeys.enable = true;
}
