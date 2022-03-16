flake: {
  config,
  lib,
  ...
}: let
  cfg = config.netboot;
in {
  options = with lib; {
    netboot = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to generate a netboot image.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the image module
    (args @ {pkgs, ...}: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/installer/netboot/netboot.nix" args;
      config = lib.mkIf cfg.enable module.config;
    in
      module // {inherit config;})
  ];
}
