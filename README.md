# hs-mx

`hs-mx` is a Haskell-first rewrite of the remote session workflow currently
built around `zmx`.

The first milestone is intentionally narrow and verifiable:

- model session names and metadata cleanly
- provide structured `list --json` output for remote wrappers
- keep all state in simple files under a deterministic runtime directory

Current commands:

- `hs-mx paths`
- `hs-mx session-name <project-path>`
- `hs-mx open-project <project-path> [--json]`
- `hs-mx list [--json]`

The PTY-backed daemon and attach flow come next.
