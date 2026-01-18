# Repository Guidelines

## Project Structure & Module Organization
- Root flake: `flake.nix` defines inputs, common modules, and per-host systems (e.g., `macbookpro2025`, `macbookpro2025-install`, `macbookpro2017`, `desktop2022`, `nucbox2022`).
- NixOS modules: `nixos-modules/` with profiles under `nixos-modules/profiles/` (hardware-specific and shared), plus service modules (`llm`, `dotool`, `mymux`, `whisper`).
- Locks: `flake.lock`, `system.lock`

## Build, Test, and Development Commands
- Evaluate a system (no build):  
  `XDG_CACHE_HOME=/tmp/xdg-cache nix eval .#nixosConfigurations.macbookpro2025.config.system.build.toplevel.drvPath`
- Build/apply to target (example for macbookpro2025):  
  `XDG_CACHE_HOME=/tmp/xdg-cache sudo nixos-rebuild test --flake .#macbookpro2025 --target-host root@<host> --build-host root@<host>`
