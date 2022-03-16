flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.demo;
in {
  options = with lib; {
    profiles.demo = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable demo configuration profile which includes a demo user with demo password and autologin.
        '';
      };
    };
  };

  imports = [
    flake.nixosModules.graphical
    # Conditionally import the profile module
    (args: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/demo.nix" args;
      config = lib.mkIf cfg.enable (builtins.removeAttrs module ["imports"]
        # Fix import of graphical profile
        // {
          profiles.graphical.enable = true;
        });
    in
      module // {inherit config;})
  ];
}
