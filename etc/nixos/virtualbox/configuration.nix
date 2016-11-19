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

  # services.xserver.videoDrivers = [ "virtualbox" "modesetting" ]; # (recent bug in updating guest additions)
}
