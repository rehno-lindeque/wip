flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.minimal;
in {
  options = with lib; {
    profiles.minimal = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable a minimal profile with graphical stuff, documentation, locales and sound disabled.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/minimal.nix" args;
      config = lib.mkIf cfg.enable module;
    in {inherit config;})
  ];
}
