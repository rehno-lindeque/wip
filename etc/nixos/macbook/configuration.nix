{
  pkgs
, ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      ./boot.nix
      ./networking.nix
      ./powerManagement.nix
      ./services.nix
    ];
}
