{hs-mx, jq, pkgs}:
pkgs.writeShellApplication {
  name = "zmx-project-list-detached";
  runtimeInputs = [hs-mx jq];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    hs-mx list --json 2>/dev/null | jq -r '
      .[]
      | select(.AttachedClients == 0 and (.Name | startswith("projects.")))
      | "\(.Name | ltrimstr("projects."))\t\(.WorkingDirectory)"
    '
  '';
}
