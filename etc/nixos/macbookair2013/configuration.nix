{
  pkgs
, ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      # Configuration for all macbook hardware
      ../macbook/configuration.nix
      # Specific configuration for my macbook air
      ./boot.nix
      ./fileSystems.nix
      ./networking.nix
      ./nix.nix
      ./nixpkgs.nix
      ./users.nix
    ];
}
