{
  coreutils,
  fuzzel,
  ghostty,
  openssh,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "desktop2022-zmx-resume";
  runtimeInputs = [coreutils fuzzel ghostty openssh];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    selection="$({
      ssh \
        -o ControlMaster=auto \
        -o ControlPersist=10m \
        -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
        desktop2022 \
        bash -lc 'zmx-project-list-detached' || true
    } | fuzzel --dmenu --prompt "desktop2022 session> ")"

    if [[ -z "$selection" ]]; then
      exit 0
    fi

    session_suffix="$(printf '%s' "$selection" | cut -f1)"
    session_name="projects.$session_suffix"

    # shellcheck disable=SC2016
    exec ghostty -e ssh \
      -o ControlMaster=auto \
      -o ControlPersist=10m \
      -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
      -t desktop2022 \
      bash -lc 'exec zmx attach "$1"' _ "$session_name"
  '';
}
