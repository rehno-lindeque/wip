{ pkgs
, ...
}:

{
  hardware = {

    # amdHybridGraphics
    # bluetooth
    # bumblebee
    # cpu
    # enableAllFirmware
    # enableKSM
    # firmware
    # nvidiaOptimus

    opengl = {
      enable = true;
      # driSupport = true;      # ?
      # driSupport32Bit = true; # ?
      # package
      # package32
      # s3tcSupport = true; # use patent encumbered texture-compression feature
      # videoDrivers
    };

    # parallels
    # pcmcia
    # pulseaudio
    # sane
    # trackpoint

    pulseaudio = {
      enable = true;
      daemon.logLevel = "error";
      support32Bit = true;
      # package = pkgs.pulseaudioFull;
    };

    /* sane = */
    /*   { */
    /*     enable = true; # Enable this to use a scanner */
    /*     extraBackends = [ pkgs.hplipWithPlugin ]; # HP drivers */
    /*   }; */
  };

  sound.enable = true;
  sound.enableOSSEmulation = false;
}
