{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../macbookpro115/configuration.nix
    ];

  # Set the host name for this computer
  networking = {
    hostName = # Define your hostname. #gitignore
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f1e38edd-d1ae-47fe-b7cb-aaaafb0f2b45";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/67E3-17ED";
      fsType = "vfat";
    };

  swapDevices =
    [
      {
        device = "/dev/disk/by-uuid/9c2c7f99-57c7-42a6-bf82-424009b17e18";
      }
    ];

  # This is an alternative way of preventing your local builds from being garbage collected
  system.extraDependencies = [
    #gitignore
  ];

}
