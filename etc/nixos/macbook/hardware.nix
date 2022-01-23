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

    # enable bluetooth as needed, keep it disabled to use less battery (disabled by default)
    # bluetooth.enable = true;

    # Enable YubiKey support
    yubikey.enable = true;

    # Grant group access to the keyboard backlight.
    macbook.leds.enable = true;

    # disable sd card reader to save on battery (enabled by default)
    macbook.sdCardReader.enable = false;
  };

  # bluetooth manager service
  # services.blueman.enable = true;
}
