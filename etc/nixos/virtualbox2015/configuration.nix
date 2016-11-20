{
  ...
}:

{
  imports =
    [
      # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      # Configuration for all virtualbox VMs
      ../virtualbox/configuration.nix
      # Specific configuration for my virtualbox VM
      ./boot.nix
      ./fileSystems.nix
      ./fonts.nix
      ./networking.nix
      ./nix.nix
      ./nixpkgs.nix
      ./services.nix
      ./users.nix
    ];
}
