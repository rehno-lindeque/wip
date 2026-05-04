# hs-mx

`hs-mx` is a Haskell-first rewrite of the remote session workflow currently
built around `zmx`.

The first milestone is intentionally narrow and verifiable:

- model session names and metadata cleanly
- provide structured `list --json` output for remote wrappers
- keep all state in simple files under a deterministic runtime directory
- support persistent detached shell sessions with a small Haskell daemon

Current commands:

- `hs-mx paths`
- `hs-mx session-name <project-path>`
- `hs-mx start <session-name> [--cwd <dir>] [--command <shell-snippet>]`
- `hs-mx attach <session-name> [--cwd <dir>]`
- `hs-mx list [--json]`
- `hs-mx history <session-name>`
- `hs-mx kill <session-name>`
- `hs-mx open-project <project-path> [--json]`

Example detached workflow:

```bash
nix run .#hs-mx -- start smoke --cwd /tmp --command "echo hello"
nix run .#hs-mx -- history smoke
```
