{
  ...
}:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/24103c2c-a659-4273-b139-69750693a131";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/31220780-f07d-4604-959b-4fe1732b45b5";
      fsType = "ext4";
    };

  fileSystems."/tmp/ram" = 
    {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=5m" ];
    };

  swapDevices =
    [ # { label = "swap"; }
      { device = "/dev/disk/by-uuid/e990939c-a825-497e-aec6-facc74823e90"; }
    ];
}
