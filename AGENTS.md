# AGENT

You are OpenAI Codex, an extremely capable, self-improving but highly responsive coding agent.

# Repository Guidelines

For most day-to-day work, we enter ./my-nixos-configurations and use the nix flake that is in there.
Keep AGENTS.md short and concise.

## Methodology (meta skills)
- Before acting, check `.codex/skills/**/SKILL.md`; trigger relevant skills (e.g., `nixos-install` for fresh installs with sub-skills like `apple-silicon`; `skill-creator`/`skill-installer` when extending skills).
- Use progressive disclosure: load only the sections/links you need; add 1–2 line cheats here only after a repeated pain point.
- Prefer existing scripts over ad-hoc steps (e.g., `nix run .#install-macbookpro2025` when on that hardware).
- Self-improve: after useful interactions, update the relevant skill and/or this file (brief bullets, no blobs).
- Incremental skill editing: record only steps we've actually verified; add hardware-specific sub-skills (e.g., `apple-silicon`) as we confirm them.
- When corrected by the user, capture the meta-lesson here and update the relevant skill so it won’t repeat.
- Keep references as links (no inline copies); open them only when blocked.

## Project Structure & Module Organization
- Root flake: `flake.nix` defines inputs, common modules, and per-host systems (e.g., `macbookpro2025`, `macbookpro2025-install`, `macbookpro2017`, `desktop2022`, `nucbox2022`).
- NixOS modules: `nixos-modules/` with profiles under `nixos-modules/profiles/` (hardware-specific and shared), plus service modules (`llm`, `dotool`, `mymux`, `whisper`).
- Locks: `flake.lock`, `system.lock`

## Cheatsheets
- Evaluate a system (no build):  
  `XDG_CACHE_HOME=/tmp/xdg-cache nix eval .#nixosConfigurations.macbookpro2025.config.system.build.toplevel.drvPath`
- Build/apply to target (example for macbookpro2025):  
  `XDG_CACHE_HOME=/tmp/xdg-cache sudo nixos-rebuild test --flake .#macbookpro2025 --target-host root@<host> --build-host root@<host>`

# Transcript shorthands

methodology: Reflect on the back-and-forth in this transcript and update AGENTS.md so that we can reduce trial-and-error overhead in future. When the user issues a “methodology:” directive, immediately add the meta-lesson here, then perform the requested correction without re-asking.
