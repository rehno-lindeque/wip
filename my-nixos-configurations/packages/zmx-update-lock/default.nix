{pkgs}:
pkgs.writeShellApplication {
  name = "zmx-update-lock";
  runtimeInputs = with pkgs; [git nix];
  text = ''
    set -euo pipefail

    repo_root="$(git rev-parse --show-toplevel)"
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    git clone --depth 1 --branch v0.5.0 https://github.com/neurosnap/zmx.git "$tmp_dir/zmx"
    nix run github:Cloudef/zig2nix/8b6ec85bccdf6b91ded19e9ef671205937e271e6#zon2nix -- "$tmp_dir/zmx/build.zig.zon"
    install -Dm644 "$tmp_dir/zmx/build.zig.zon.nix" "$repo_root/packages/zmx/build.zig.zon.nix"
  '';
}
