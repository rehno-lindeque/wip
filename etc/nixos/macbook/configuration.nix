{
  pkgs
, ...
}:

{
  imports =
    [
      # ./boot.nix
      ./hardware.nix
      ./networking.nix
      ./powerManagement.nix
      ./programs.nix
      ./services.nix
    ];
}
