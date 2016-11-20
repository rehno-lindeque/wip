{ pkgs
, ...
}:

{
  hardware = {
    # bluetooth.enable = true;
    enableAllFirmware = true;
    opengl = {
      driSupport = true;
      driSupport32Bit = false;
      s3tcSupport = true; # use patent encumbered texture-compression feature
    };
  };
}
