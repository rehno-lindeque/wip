{pkgs}:
  pkgs.writeShellApplication {
    name = "nix-run";
    runtimeInputs = [pkgs.nix];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [[ -z "''${FLAKE_REF:-}" ]]; then
        args=("$@")
        installable=""
        sep_index=-1

        for i in "''${!args[@]}"; do
          if [[ "''${args[$i]}" == "--" ]]; then
            sep_index=$i
            break
          fi
        done

        i=0
        while [[ $i -lt ''${#args[@]} ]]; do
          if [[ $sep_index -ge 0 && $i -ge $sep_index ]]; then
            break
          fi

          arg="''${args[$i]}"
          if [[ "$arg" == "--" ]]; then
            break
          fi

          if [[ "$arg" == --*=* ]]; then
            i=$((i + 1))
            continue
          fi

          if [[ "$arg" == -* ]]; then
            skip=0
            case "$arg" in
              --arg|--argstr|--arg-from-file|--override-input|--override-flake|--option|--set-env-var)
                skip=2
                ;;
              --arg-from-stdin|--expr|--file|--include|--inputs-from|--update-input|--output-lock-file|--reference-lock-file|--keep-env-var|--unset-env-var|--eval-store|--log-format)
                skip=1
                ;;
              -I|-f|-k|-u)
                skip=1
                ;;
              -s)
                skip=2
                ;;
            esac
            i=$((i + 1 + skip))
            continue
          fi

          installable="$arg"
          break
        done

        if [[ -n "$installable" ]]; then
          ref="$installable"
          if [[ "$ref" == *"#"* ]]; then
            ref="''${ref%%#*}"
          fi
          export FLAKE_REF="$ref"
        fi
      fi

      exec nix run "$@"
    '';
  }
