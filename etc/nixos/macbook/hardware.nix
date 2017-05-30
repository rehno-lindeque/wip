{
  pkgs
, ...
}:

{
  hardware = {
    enableAllFirmware = true;
    opengl = {
      driSupport = true;
      driSupport32Bit = false;
      s3tcSupport = true; # use patent encumbered texture-compression feature
    };

    # enable bluetooth as needed, keep it disabled to use less battery
    bluetooth.enable = false;
  };
}
