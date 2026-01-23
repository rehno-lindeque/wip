{pkgs, name}:
  pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [pkgs.nix];
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      FLAKE_REF="\${FLAKE_REF:-flake:my-nixos-configurations}"
      exec nix run "\${FLAKE_REF}#${name}" -- "$@"
    '';
  }
