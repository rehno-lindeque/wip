# My nixos configurations
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

NixOS configurations for various systems I work with.

## Pitfalls

* With nix unstable 2.9 use:

```
sudo nixos-rebuild switch --flake path:.#nucbox
```

to avoid git issues

* To install `desktop2022` configuration from github use:

```
nixos-install --root /mnt github:rehno-lindeque/wip?dir=my-nixos-configurations#desktop2022
```

This is a workaround for the present issue with using subflakes:

```
error: cannot fetch input 'path:./my-nixos-configurations?...' because it is a relative path
```

## Notes

* Base configurations are nixos modules
* Custom packages, modules and hardware configuration not specific to my environment is sourced from separately maintained flakes/repos.

