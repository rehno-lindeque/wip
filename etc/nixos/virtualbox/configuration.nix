{
  ...
}:

{
  imports =
    [
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
      ./boot.nix
      ./virtualisation.nix
    ];
}
