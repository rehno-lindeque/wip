# NixOS images
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS modules that help for building custom images for different kinds of media.

**Important:** This package isn't intended to be used by itself. If you are just trying to build a regular NixOS
installer image, it's probably more productive to build one directly from nixpkgs.

Some resources that might help with this:

* https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
* https://hoverbear.org/blog/nix-flake-live-media
* https://nix.dev/tutorials/building-bootable-iso-image
* https://nixos.wiki/wiki/Netboot


## Notes

Includes image modules defined in nixpkgs:

* [nixos/modules/installer/sd-card/sd-image](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image.nix)
* [nixos/modules/installer/cd-dvd/iso-image](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/iso-image.nix)
* [nixos/modules/installer/netboot](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/netboot/netboot.nix)

You may wish to combine this with the NixOS profiles defined in
[https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles](nixos/modules/profiles).


## Modifications

Most modules are slightly modified in order to include an `enable` option which defaults to `false`.

## Contributing

I'm not too interested in maintaining this repo for the long term. If others do find this useful, I would suggest
we contribute back to mainline nixpkgs or otherwise I'd also welcome transferring ownership to [nix-community](https://github.com/nix-community).
