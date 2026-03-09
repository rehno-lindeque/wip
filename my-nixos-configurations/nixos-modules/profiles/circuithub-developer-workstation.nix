{
  config,
  lib,
  ...
}: let
  cfg = config.circuithubConfigurations.developerWorkstation;
in {
  options = with lib; {
    circuithubConfigurations.developerWorkstation = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable CircuitHub's configuration profile for developer workstations.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        substituters = [
          "s3://circuithub-nix-binary-cache?profile=circuithub-binary-cache&region=eu-central-1"
        ];
        trusted-public-keys = [
          "hydra.circuithub.com:tt5GsRxotmMj6nDFuiYGxKEWSZiDiywb0OEDdrfRXZk="
        ];
      };
      registry = {
        circuithub = {
          from = {
            id = "circuithub";
            type = "indirect";
          };
          to = {
            type = "git";
            url = "ssh://git@github.com/circuithub/mono.git";
          };
        };
        circuithub-configurations = {
          from = {
            id = "circuithub-configurations";
            type = "indirect";
          };
          to = {
            type = "git";
            url = "ssh://git@github.com/circuithub/nixos-configurations.git";
          };
        };
      };
    };
  };
}
