# NixOS profiles
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS configuration profiles that are not specific to any particular machine.

The [chapter on profiles](https://nixos.org/manual/nixos/stable/#ch-profiles) in the NixOS manual documents each of these profiles:

* [All Hardware](https://nixos.org/manual/nixos/stable/index.html#sec-profile-all-hardware)
  ```nix
  {
    profiles.allHardware.enable = true;
  }
  ```

* [Base](https://nixos.org/manual/nixos/stable/index.html#sec-profile-base)
  ```nix
  {
    profiles.base.enable = true;
  }
  ```

* [Clone Config](https://nixos.org/manual/nixos/stable/index.html#sec-profile-clone-config)
  ```nix
  {
    profiles.cloneConfig.enable = true;
  }
  ```
* [Demo](https://nixos.org/manual/nixos/stable/index.html#sec-profile-demo)
  ```nix
  {
    profiles.demo.enable = true;
  }
  ```

* [Docker Container](https://nixos.org/manual/nixos/stable/index.html#sec-profile-docker-container)
  ```nix
  {
    profiles.dockerContainer.enable = true;
  }
  ```

* [Graphical](https://nixos.org/manual/nixos/stable/index.html#sec-profile-graphical)
  ```nix
  {
    profiles.graphical.enable = true;
  }
  ```

* [Hardened](https://nixos.org/manual/nixos/stable/index.html#sec-profile-hardened)
  ```nix
  {
    profiles.hardened.enable = true;
  }
  ```

* [Headless](https://nixos.org/manual/nixos/stable/index.html#sec-profile-headless)
  ```nix
  {
    profiles.headless.enable = true;
  }
  ```

* [Installation Device](https://nixos.org/manual/nixos/stable/index.html#sec-profile-installation-device)
  ```nix
  {
    profiles.installationDevice.enable = true;
  }
  ```

* [Minimal](https://nixos.org/manual/nixos/stable/index.html#sec-profile-minimal)
  ```nix
  {
    profiles.minimal.enable = true;
  }
  ```

* [QEMU Guest](https://nixos.org/manual/nixos/stable/index.html#sec-profile-qemu-guest)
  ```nix
  {
    profiles.qemuGuest.enable = true;
  }
  ```

## Notes

* Currently all profiles are sourced from the nixpkgs source tree under [/nixos/modules/profiles](https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/profiles).

## Modifications

Most modules are slightly modified in order to include an `enable` option which defaults to `false`.

## Contributing

I'm not too interested in maintaining this repo for the long term. If others do find this useful, I would suggest
we contribute back to mainline nixpkgs or otherwise I'd also welcome transferring ownership to [nix-community](https://github.com/nix-community).
