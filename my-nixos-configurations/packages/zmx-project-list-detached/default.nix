{pkgs, zmx}:
pkgs.writeShellApplication {
  name = "zmx-project-list-detached";
  runtimeInputs = [zmx];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    zmx list 2>/dev/null | while IFS=$'\t' read -r name _pid clients _created dir; do
      name="''${name#session_name=}"
      clients="''${clients#clients=}"
      dir="''${dir#started_in=}"

      if [[ "$clients" == "0" && "$name" == projects.* ]]; then
        printf '%s\t%s\n' "''${name#projects.}" "$dir"
      fi
    done
  '';
}
