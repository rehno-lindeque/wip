{
  fuzzel,
  ghostty,
  openssh,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "desktop2022-project-session";
  runtimeInputs = [fuzzel ghostty openssh];
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
          'cd "$HOME/projects" 2>/dev/null && for path in */ */*/; do [[ -d "$path" ]] && printf "%s\n" "''${path%/}"; done'
      } 2>/dev/null || true)"
      project_name="$(printf '%s\n' "$project_names" | fuzzel --dmenu --prompt "desktop2022 project> ")"
    fi

    if [[ -z "$project_name" ]]; then
      exit 0
    fi

    quoted_project_name="$(printf '%q' "$project_name")"
    remote_command="$(cat <<REMOTE
    project_name=$quoted_project_name
    project_name="\''${project_name#./}"
    project_path="\$HOME/projects/\$project_name"
    session_suffix="\$(printf '%s' "\$project_name" | tr '/[:space:]' '..' | tr -cs '[:alnum:]._-' '-')"
    session_name="projects.\$session_suffix"

    if [[ ! -d "\$project_path" ]]; then
      printf 'No such project: %s\n' "\$project_path" >&2
      exec "\$SHELL" -l
    fi

    exec sesh attach "\$session_name" --cwd "\$project_path" --tags project,desktop2022
REMOTE
    )"

    exec ghostty -e ssh \
      -o ControlMaster=auto \
      -o ControlPersist=10m \
      -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
      -t desktop2022 \
      "$remote_command"
  '';
}
