{
  autossh,
  fuzzel,
  ghostty,
  openssh,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "desktop2022-project-session";
  runtimeInputs = [autossh fuzzel ghostty openssh];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    project_name="''${1:-}"
    if [[ -z "$project_name" ]]; then
      project_names="$({
        ssh \
          -o ControlMaster=auto \
          -o ControlPersist=10m \
          -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
          desktop2022 \
          'cd "$HOME/projects" 2>/dev/null && find . -maxdepth 4 \( -type d \( -name .git -o -name node_modules -o -name .direnv -o -name result -o -name target -o -name dist -o -name build -o -name vendor \) -prune \) -o \( -type f -name flake.nix -printf "%h\n" \) | sed "s#^\./##" | sort -u'
      } 2>/dev/null || true)"

      project_name="$(printf '%s\n' "$project_names" | fuzzel \
        --config "''${XDG_CONFIG_HOME:-$HOME/.config}/fuzzel/desktop2022-project-session.ini" \
        --dmenu \
        --prompt "desktop2022> ")"
    fi

    if [[ -z "$project_name" ]]; then
      exit 0
    fi

    session_suffix="$(printf '%s' "$project_name" | tr '/[:space:]' '..' | tr -cs '[:alnum:]._-' '-')"
    session_id="$(date -u +%Y%m%dT%H%M%SZ)-$$"
    session_name="projects.$session_suffix.$session_id"

    quoted_project_name="$(printf '%q' "$project_name")"
    quoted_session_name="$(printf '%q' "$session_name")"
    remote_command="$(cat <<REMOTE
    project_name=$quoted_project_name
    session_name=$quoted_session_name
    project_name="\''${project_name#./}"
    project_path="\$HOME/projects/\$project_name"

    if [[ ! -d "\$project_path" ]]; then
      mapfile -t project_matches < <(
        cd "\$HOME/projects" 2>/dev/null &&
          find . -type f -path "*/\$project_name/flake.nix" -printf '%h\n' |
          sed 's#^\./##'
      )
      if [[ "\''${#project_matches[@]}" -eq 1 ]]; then
        project_name="\''${project_matches[0]}"
        project_path="\$HOME/projects/\$project_name"
      fi
    fi

    if [[ ! -d "\$project_path" ]]; then
      printf 'No such project: %s\n' "\$project_path" >&2
      exec "\$SHELL" -l
    fi

    exec sesh attach "\$session_name" --cwd "\$project_path" --tags project,desktop2022
REMOTE
    )"

    exec ghostty -e autossh -M 0 -q \
      -o ServerAliveInterval=30 \
      -o ServerAliveCountMax=3 \
      -t desktop2022 \
      "$remote_command"
  '';
}
