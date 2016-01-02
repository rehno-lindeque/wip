{
  ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      # TODO...
      # Configuration for all virtualbox VMs
      ../virtualbox/configuration.nix
      # Specific configuration for my virtualbox VM
      ./boot.nix
      ./fonts.nix
      ./networking.nix
      ./nixpkgs.nix
      ./users.nix
    ];
}
