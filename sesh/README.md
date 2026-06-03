# sesh

`sesh` is a small Haskell session manager aimed mostly at my own remote-shell workflow.

It exists partly because `zmx` was awkward to package and integrate cleanly in my Nix setup. If you want the more mature and more fully featured tool, use `zmx` first. `sesh` is narrower: it focuses on detached shell sessions, simple metadata, and local/remote session selection.

## Status

- personal-use tool first
- works well for detached shell sessions and remote attach workflows
- much less mature than `zmx`
- not trying to compete on terminal-state restoration breadth

## Scope

Core `sesh` stays generic:

- start a named session with an optional working directory
- attach and detach clients without killing the session
- list sessions as JSON for wrappers and pickers
- track tags and attached-client count
- persist a plain output log for later inspection

History logs are capped at 16 MiB per session by default. Set
`SESH_HISTORY_LIMIT_BYTES` to override the cap, or set it to `0` to disable
history writes.

Project naming conventions and paths such as `~/projects/...` intentionally live outside the core tool in wrappers.

## Commands

- `sesh paths`
- `sesh start <session-name> [--cwd <dir>] [--tags tag,tag] [--command <shell-snippet>]`
- `sesh attach <session-name> [--cwd <dir>] [--tags tag,tag] [--command <shell-snippet>]`
- `sesh list [--json]`
- `sesh history <session-name>`
- `sesh kill <session-name>`

Example:

```bash
nix run .#sesh -- start smoke --cwd /tmp --tags test --command "echo hello"
nix run .#sesh -- history smoke
```

## Prior Art

`sesh` is inspired primarily by `zmx`, which remains the more mature project and the best point of comparison.

- `zmx`: session persistence, multiple clients, strong terminal behavior, broader feature set
- `zmosh`: interesting remote-first fork of `zmx` with encrypted UDP auto-reconnect

Right now `sesh` does not try to copy `zmosh`'s reconnecting network transport. The immediate goal is a simple, Nix-friendly remote session workflow.

## License

`sesh` is MIT-licensed.

`zmx` and `zmosh` are also MIT-licensed. This project is an independent reimplementation inspired by their design, not a source fork.
