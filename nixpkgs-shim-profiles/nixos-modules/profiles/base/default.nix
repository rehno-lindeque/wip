flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.base;
in {
  options = with lib; {
    profiles.base = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable a base configuration including software packages included in the minimal installation CD.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args @ {pkgs, ...}: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/base.nix" args;
      config = lib.mkIf cfg.enable module;
    in {inherit config;})
  ];
}
