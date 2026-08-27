{
  name,
  targetHost ? "",
  nixosConfiguration ? targetHost,
  lib,
  writeShellApplication,
  gh,
  nix,
  nix-run,
  openssh,
  sudo,
}:
  writeShellApplication {
    inherit name;
    runtimeInputs = [gh nix nix-run openssh sudo];
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

      ${lib.optionalString (targetHost != "") ''
        local_host="$(hostname -s)"
        if [[ "${targetHost}" != "$local_host" && "$EUID" -eq 0 ]]; then
          if [[ -z "''${SUDO_USER:-}" || "$SUDO_USER" == root ]]; then
            echo "${name}: run via sudo from a non-root user" >&2
            exit 1
          fi

          remote_args=(
            sudo -n /run/current-system/sw/bin/nixos-rebuild
            "$@"
            --flake "$FLAKE_REF#${nixosConfiguration}"
          )
          printf -v remote_command '%q ' "''${remote_args[@]}"
          exec sudo -H -u "$SUDO_USER" \
            ssh -o BatchMode=yes -- "${targetHost}" "$remote_command"
        fi
      ''}

      exec nix-run "''${FLAKE_REF}#${name}" "$@"
    '';
  }
