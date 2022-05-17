# My nixos configurations
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS configurations for various systems I work with.

## Pitfalls

With nix unstable 2.9 use:

```
sudo nixos-rebuild switch --flake path:.#nucbox
```

to avoid git issues


## Notes

* Base configurations are nixos modules
* Custom packages, modules and hardware configuration not specific to my environment is sourced from separately maintained flakes/repos.

