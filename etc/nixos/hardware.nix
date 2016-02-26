{ pkgs
, ...
}:

{
  hardware = {

    # amdHybridGraphics
    # bluetooth
    # bumblebee
    # cpu
    # enableKSM
    # firmware
    # nvidiaOptimus

    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = false;
      s3tcSupport = true; # use patent encumbered texture-compression feature
    };

    pulseaudio = {
      enable = true;
      daemon.logLevel = "error";
      support32Bit = true;
      package = pkgs.pulseaudioFull; # TODO: what does this do?
    };
  };
}
