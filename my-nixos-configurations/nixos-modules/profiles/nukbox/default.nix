{...}: {
  profiles = {
    # hardened.enable = true; # temporarily broken
    workstation.enable = true;
    circuithub.developerWorkstation.enable = true;
    personalized = {
      enable = true;
    };
    desktop.enable = true;
  };

  boot.loader = {
    # Use the systemd-boot EFI boot loader as it appears to be very simple
    systemd-boot.enable = true;
  };

  # TODO: kernel modules (add to nixos-hardware)
  # boot = {
  #   initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  #   kernelModules = [ "kvm-intel" ];
  #   extraModulePackages = [];
  # };

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

  # TODO
  # nix.maxJobs = lib.mkDefault 4;
  # powerManagement.cpuFreqGovernor = "powersave";
}
