flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.hardened;
in {
  options = with lib; {
    profiles.hardened = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable a hardened configuration profile which sets various flags in security.*, boot.*, etc.
          You may wish to try turning this off if you experience stability issues.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args @ {
      config,
      lib,
      pkgs,
      ...
    }: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/hardened.nix" args;
      config = lib.mkIf cfg.enable module;
    in {inherit config;})
  ];
}
