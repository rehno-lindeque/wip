# A work in progress, into perpetuity
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

My technological world as a nix flake (and sub-flakes).

## Notes

* Sub-flakes prefixed with `my-` are specific to my environment and probably not too interesting unless you are setting up a system from scratch and want to crib my layout.

## Layout

```
.
├── my-dev-shells
│   └── dev-shells
│       ├── nix-environment
│       └── python-environment
└── my-nixos-configurations
    ├── apps
    ├── dev-shell
    └── nixos-modules
        └── profiles
            ├── common
            ├── installer
            ├── nucbox
            ├── personalized
            ├── preferences
            └── workstation
```
