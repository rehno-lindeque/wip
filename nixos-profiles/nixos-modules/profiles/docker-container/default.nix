flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.dockerContainer;
in {
  options = with lib; {
    profiles.dockerContainer = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the base profile from which the official Docker images are generated.
        '';
      };
    };
  };

  imports = [
    flake.nixosModules.minimal
    flake.nixosModules.cloneConfig
    # Conditionally import the profile module
    (args: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/docker-container.nix" args;
      config = lib.mkIf cfg.enable (
        builtins.removeAttrs module ["imports"]
        # Fix import of profiles
        // {
          profiles.minimal.enable = true;
          profiles.cloneConfig.enable = true;
        }
        # Fix import of channels
        // import "${flake.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix" args
      );
    in
      module // {inherit config;})
  ];
}
