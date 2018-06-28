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

    # microcode updates for intel processors
    # See
    # * https://wiki.archlinux.org/index.php/microcode
    # * https://github.com/yegortimoshenko/overlay/blob/26267e8ab4a1d2355f47c73ba7309254ba6bbe1a/modules/profiles/apple.nix
    cpu.intel.updateMicrocode = true;

    # Grant group access to the keyboard backlight.
    leds.enable = true;
  };
}
