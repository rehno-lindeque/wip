flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.allHardware;
in {
  options = with lib; {
    profiles.allHardware = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Turn on a configuration profile that enables all hardware supported by NixOS.
          It's not intended for a specific system installation since it mostly just adds firmware bloat, but it can be
          used on live media that needs to run anywhere it is used.

          See https://github.com/nixos/nixos-hardware for hardware-specific configuration profiles.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args @ {pkgs, ...}: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/all-hardware.nix" args;
      config = lib.mkIf cfg.enable (
        # Fix import of zydas-zd1211 profile
        import "${flake.inputs.nixpkgs}/nixos/modules/hardware/network/zydas-zd1211.nix" args
        // builtins.removeAttrs module ["imports"]
      );
    in {inherit config;})
  ];
}
