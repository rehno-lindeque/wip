{pkgs, name}:
  pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [pkgs.gh pkgs.nix];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      FLAKE_REF="''${FLAKE_REF:-flake:my-nixos-configurations}"
      gh_token="''${GH_TOKEN:-''${GITHUB_TOKEN:-}}"
      if [[ -z "$gh_token" ]] && command -v gh >/dev/null 2>&1; then
        gh_token="$(gh auth token 2>/dev/null || true)"
      fi
      if [[ -n "$gh_token" ]]; then
        if [[ -n "''${NIX_CONFIG:-}" ]]; then
          NIX_CONFIG="access-tokens = github.com=$gh_token
''${NIX_CONFIG}"
        else
          NIX_CONFIG="access-tokens = github.com=$gh_token"
        fi
        export NIX_CONFIG
      fi
      exec nix run "''${FLAKE_REF}#${name}" -- "$@"
    '';
  }
