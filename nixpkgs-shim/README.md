# A nixpkgs (NixOS) flake, but with more modules exposed
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Right now nixpkgs doesn't expose everything that is used internally in its flake. This defines a flake with more of the internal modules exposed.

In particular, it includes installer profiles and image building modules.

## Modifications

Most modules are slightly modified in order to include an `enable` option which defaults to `false`.

## Contributing

I'm not too interested in maintaining this repo for the long term. If others do find this useful, I would suggest
we contribute back to mainline nixpkgs or otherwise I'd also welcome transferring ownership to [nix-community](https://github.com/nix-community).
