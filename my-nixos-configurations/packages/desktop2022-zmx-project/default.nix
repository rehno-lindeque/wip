{
  pkgs,
  fuzzel,
  ghostty,
  openssh,
}:
pkgs.writeShellApplication {
  name = "desktop2022-zmx-project";
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
      bash -lc 'exec zmx-project-open "$1"' _ "$project_name"
  '';
}
