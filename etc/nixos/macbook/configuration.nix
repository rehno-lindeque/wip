{
  pkgs
, ...
}:

{
  imports =
    [
      ./boot.nix
      ./environment.nix
      ./hardware.nix
      ./networking.nix
      ./powerManagement.nix
      ./programs.nix
      ./services.nix
    ];
}
