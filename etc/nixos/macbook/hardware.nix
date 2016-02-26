{ pkgs
, ...
}:

{
  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
  };
}
