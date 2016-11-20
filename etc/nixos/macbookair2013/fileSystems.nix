{
  ...
}:

{
  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "/old-root" = {
      device = "/dev/sda6";
      fsType = "ext4";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/17db0788-ce59-449f-8f44-35a41fc92277"; }
    ];
}
