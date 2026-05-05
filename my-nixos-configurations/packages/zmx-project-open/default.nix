{
  bash,
  coreutils,
  gnused,
  sesh,
  pkgs,
}:
pkgs.writeShellApplication {
  name = "zmx-project-open";
  runtimeInputs = [bash coreutils gnused sesh];
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    project_name="''${1:-}"
    if [[ -z "$project_name" ]]; then
      printf 'Usage: zmx-project-open <path-under-~/projects>\n' >&2
      exit 1
    fi

    project_name="''${project_name#./}"
    project_path="$HOME/projects/$project_name"
    session_suffix="$(printf '%s' "$project_name" | tr '/[:space:]' '..' | tr -cs '[:alnum:]._-' '-')"
    session_name="projects.$session_suffix"

    if [[ ! -d "$project_path" ]]; then
      printf 'No such project: %s\n' "$project_path" >&2
      exec "$SHELL" -l
    fi

    exec sesh attach "$session_name" --cwd "$project_path" --tags project
  '';
}
