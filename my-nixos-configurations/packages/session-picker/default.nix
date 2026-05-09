{
  fuzzel,
  ghostty,
  jq,
  openssh,
  pkgs,
  sesh,
}:
pkgs.writeShellApplication {
  name = "session-picker";
  runtimeInputs = [fuzzel ghostty jq openssh sesh];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    local_json="$(sesh list --json 2>/dev/null || printf '[]')"
    remote_json="$({
      ssh \
        -o ControlMaster=auto \
        -o ControlPersist=10m \
        -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
        desktop2022 \
        'exec sesh list --json'
    } 2>/dev/null || printf '[]')"

    selection="$({
      jq -rn \
        --argjson local "$local_json" \
        --argjson remote "$remote_json" '
          [
            ($local[]? | . + {scope: "local"}),
            ($remote[]? | . + {scope: "desktop2022"})
          ]
          | map(select(.AttachedClients == 0))
          | sort_by(.UpdatedAt)
          | reverse
          | .[]
          | [
              .scope,
              .Name,
              (.Tags | join(",")),
              .WorkingDirectory,
              .UpdatedAt
            ]
          | @tsv
        '
    } | fuzzel --dmenu --prompt "detached session> ")"

    if [[ -z "$selection" ]]; then
      exit 0
    fi

    scope="$(printf '%s' "$selection" | cut -f1)"
    session_name="$(printf '%s' "$selection" | cut -f2)"

    case "$scope" in
      local)
        exec ghostty -e sesh attach "$session_name"
        ;;
      desktop2022)
        quoted_session_name="$(printf '%q' "$session_name")"
        exec ghostty -e ssh \
          -o ControlMaster=auto \
          -o ControlPersist=10m \
          -o "ControlPath=$HOME/.ssh/cm-%r@%h:%p" \
          -t desktop2022 \
          "exec sesh attach $quoted_session_name"
        ;;
      *)
        printf 'Unknown session scope: %s\n' "$scope" >&2
        exit 1
        ;;
    esac
  '';
}
