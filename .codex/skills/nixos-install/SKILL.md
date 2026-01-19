---
name: nixos-install
description: "Install or reimage NixOS from live media; progressively disclose per-hardware steps. Trigger when in a live/rescue shell preparing a fresh install."
---

# NixOS Install (incremental)

Start here; branch into sub-skills (e.g., `apple-silicon`) when the hardware requires it.

Meta: only record steps we have actually performed; after each new verified step, update this skill or the appropriate sub-skill.

## Steps we have confirmed
- Prefer repo installer scripts when available (e.g., `nix run .#install-macbookpro2025` on that hardware).

## To-do (fill in after we perform them)
- Partitioning/LUKS/mount recipe, impermanence layout, firmware copy steps (delegate Apple Silicon details to sub-skill).
- ARM/PinePhone specifics (new sub-skills later).

## References
- See sub-skill references (e.g., `apple-silicon/links.md`) and open only when blocked.
