{
  config,
  lib,
  ...
}: let
  cfg = config.programs.gh.nixAuth;
in {
  options = with lib; {
    programs.gh.nixAuth.enable = mkEnableOption "bridge gh auth token into NIX_CONFIG for interactive bash sessions";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.bash.initExtra = ''
          if command -v gh >/dev/null 2>&1; then
            gh_nix_token="$(gh auth token 2>/dev/null || true)"
            if [ -n "$gh_nix_token" ]; then
              export NIX_CONFIG="access-tokens = github.com=$gh_nix_token''${NIX_CONFIG:+
$NIX_CONFIG}"
            fi
            unset gh_nix_token
          fi
        '';
      }
    ];
  };
}
