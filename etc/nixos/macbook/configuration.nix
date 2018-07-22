{
  pkgs
, ...
}:

{
  imports =
    [
      # ./boot.nix
      ./hardware.nix
      ./powerManagement.nix
      ./programs.nix
      ./services.nix
    ];
}
