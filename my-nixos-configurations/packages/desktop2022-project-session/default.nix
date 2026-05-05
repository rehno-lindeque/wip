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
      project_name="$(printf "" | fuzzel --dmenu --prompt "desktop2022 project> ")"
    fi

    if [[ -z "$project_name" ]]; then
      exit 0
    fi

    # shellcheck disable=SC2016
    exec ghostty -e ssh \
      -o ControlMaster=auto \
      -o ControlPersist=10m \
      -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
      -t desktop2022 \
      bash -lc '
        project_name="$1"
        project_name="''${project_name#./}"
        project_path="$HOME/projects/$project_name"
        session_suffix="$(printf "%s" "$project_name" | tr "/[:space:]" ".." | tr -cs "[:alnum:]._-" "-")"
        session_name="projects.$session_suffix"

        if [[ ! -d "$project_path" ]]; then
          printf "No such project: %s\n" "$project_path" >&2
          exec "$SHELL" -l
        fi

        exec sesh attach "$session_name" --cwd "$project_path" --tags project,desktop2022
      ' _ "$project_name"
  '';
}
