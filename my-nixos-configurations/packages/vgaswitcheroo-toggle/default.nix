{ pkgs }:

pkgs.writeShellApplication {
  name = "vgaswitcheroo-toggle";
  runtimeInputs = [ pkgs.coreutils pkgs.util-linux pkgs.sudo ];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    switch_file="/sys/kernel/debug/vgaswitcheroo/switch"

    usage() {
      cat <<'USAGE'
Usage: vgaswitcheroo-toggle [status|igpu|dgpu]
  status   Show current vgaswitcheroo state
  igpu     Prefer iGPU (DIGD) and power off dGPU (OFF)
  dgpu     Power on dGPU (ON) and prefer dGPU (DDIS)

Note: Switching to iGPU may blank the display if the panel is wired to the dGPU.
USAGE
    }

    # Re-exec as root if needed
    if [[ "''${EUID}" -ne 0 ]]; then
      exec sudo -- "$0" "$@"
    fi

    cmd=''${1:-status}

    # Ensure debugfs is mounted so the switch file exists
    if ! mountpoint -q /sys/kernel/debug 2>/dev/null; then
      mount -t debugfs debugfs /sys/kernel/debug || true
    fi

    if [[ ! -w "''${switch_file}" ]]; then
      echo "vgaswitcheroo: ''${switch_file} not writable or missing; is vgaswitcheroo enabled?" >&2
      exit 1
    fi

    case "''${cmd}" in
      status)
        cat "''${switch_file}"
        ;;
      igpu)
        echo "DIGD" >"''${switch_file}" || true
        sleep 0.2
        echo "OFF" >"''${switch_file}" || true
        cat "''${switch_file}"
        ;;
      dgpu)
        echo "ON" >"''${switch_file}" || true
        sleep 0.2
        echo "DDIS" >"''${switch_file}" || true
        cat "''${switch_file}"
        ;;
      -h|--help|help)
        usage
        ;;
      *)
        echo "Unknown command: ''${cmd}" >&2
        usage
        exit 1
        ;;
    esac
  '';
}
