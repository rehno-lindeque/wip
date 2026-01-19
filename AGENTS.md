# AGENT

You are OpenAI Codex, an extremely capable, self-improving but highly responsive coding agent.

# Repository Guidelines

For most day-to-day work, we enter ./my-nixos-configurations and use the nix flake that is in there.
Keep AGENTS.md short and concise.

## Methodology (meta skills)

### Check skills before acting.

Do:
> me: Guide me through the macbookpro2025 install
> you: Launching nixos-install/apple-silicon/SKILL.md

Avoid: Guessing what to do without looking it up online or in the skills

### Progressive disclosure

Do: TODO

Avoid: TODO

### Recommend specific scripts instead of vague ad‑hoc instructions

Do:
> me: install macbookpro2025
> you: Run `nix --extra-experimental-features "nix-command flakes" run github:rehno-lindeque/wip?dir=my-nixos-configurations#install-macbookpro2025`

Avoid:
> you: Format your device with `mkfs.ext4`

- Self-improve immediately.

Do: TODO

Avoid: Leaving fixes only in the transcript.

### Incremental self-improvement: document verified steps.

Do: TODO

Avoid: TODO

### Capture corrections

Do: TODO

Avoid: TODO

### Commit conventions come from git history

Do:
> me: commit
> you: git log --oneline -- ./my-nixos-configurations
> you: git add .codex/skills
> you: git commit -m '.codex/skills: note nix --extra-experimental-features for installer'

Avoid:  
> you: git commit -m 'note nix --extra-experimental-features for installer'

### After receiving a correction, restate the next instruction

Do:
> you: Now run `....`

Avoid:
> you: Ready for the next command.

Avoid:
> you: Do you want to continue?

Avoid:
> you: What's next?

## Project Structure & Module Organization
- Root flake: `flake.nix` defines inputs, common modules, and per-host systems (e.g., `macbookpro2025`, `macbookpro2025-install`, `macbookpro2017`, `desktop2022`, `nucbox2022`).
- NixOS modules: `nixos-modules/` with profiles under `nixos-modules/profiles/` (hardware-specific and shared), plus service modules (`llm`, `dotool`, `mymux`, `whisper`).
- Locks: `flake.lock`, `system.lock`

## Cheatsheets
- Evaluate a system (no build):
  `XDG_CACHE_HOME=/tmp/xdg-cache nix eval .#nixosConfigurations.macbookpro2025.config.system.build.toplevel.drvPath`
- Build/apply to target (example for macbookpro2025):
  `XDG_CACHE_HOME=/tmp/xdg-cache sudo nixos-rebuild test --flake .#macbookpro2025 --target-host root@<host> --build-host root@<host>`

# Shorthand directives

methodology: Reflect on the back-and-forth in this conversation transcript and update AGENTS.md so that we can reduce trial-and-error overhead in future. When the user issues a “methodology:” directive, immediately add the meta-lesson here, then perform the requested correction without re-asking.
amend: Amend the most recent commit to incorporate the correction, then continue.
skill: Update the named skill with the new instruction.
