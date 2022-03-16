flake: {
  config,
  lib,
  ...
}: let
  cfg = config.sdImage;
in {
  options = with lib; {
    sdImage = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to generate an SD image file.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the image module
    (args @ {pkgs, ...}: let
      module = builtins.removeAttrs (import "${flake.inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix" args) ["imports"];
      config = lib.mkIf cfg.enable module.config;
    in
      module // {inherit config;})
  ];
}
