{jq, pkgs, sesh}:
pkgs.writeShellApplication {
  name = "zmx-project-list-detached";
  runtimeInputs = [jq sesh];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    sesh list --json 2>/dev/null | jq -r '
      .[]
      | select(.AttachedClients == 0 and (.Name | startswith("projects.")))
      | "\(.Name | ltrimstr("projects."))\t\(.WorkingDirectory)"
    '
  '';
}
