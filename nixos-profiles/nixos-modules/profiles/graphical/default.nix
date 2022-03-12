flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.graphical;
in {
  options = with lib; {
    profiles.graphical = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable a graphical configuration profile based on the plasma5 desktop and including software
          used by the graphical installation CD.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/graphical.nix" args;
      config = lib.mkIf cfg.enable module;
    in {inherit config;})
  ];
}
