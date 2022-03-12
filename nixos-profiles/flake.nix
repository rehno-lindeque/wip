{
  description = "NixOS configuration profiles that are not specific to any particular machine.";

  inputs = {
    # awaiting https://github.com/NixOS/nixpkgs/pull/163635
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
  };

  outputs = {self, ...}: {
    nixosModules = {
      allHardware = import ./nixos-modules/profiles/all-hardware self;
      base = import ./nixos-modules/profiles/base self;
      cloneConfig = import ./nixos-modules/profiles/clone-config self;
      demo = import ./nixos-modules/profiles/demo self;
      dockerContainer = import ./nixos-modules/profiles/docker-container self;
      graphical = import ./nixos-modules/profiles/graphical self;
      hardened = import ./nixos-modules/profiles/hardened self;
      headless = import ./nixos-modules/profiles/headless self;
      installationDevice = import ./nixos-modules/profiles/installation-device self;
      minimal = import ./nixos-modules/profiles/minimal self;
      qemuGuest = import ./nixos-modules/profiles/qemu-guest self;
    };
  };
}
