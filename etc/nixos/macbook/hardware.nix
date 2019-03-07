{
  pkgs
, ...
}:

{
  hardware = {
    enableAllFirmware = true;
    opengl = {
      s3tcSupport = true; # use patent encumbered texture-compression feature
    };

    # enable bluetooth as needed, keep it disabled to use less battery
    # bluetooth.enable = true;

    # Grant group access to the keyboard backlight.
    leds.enable = true;
  };
}
