flake: {
  config,
  lib,
  ...
}: let
  cfg = config.isoImage;
in {
  options = with lib; {
    isoImage = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to generate an ISO image file.
        '';
      };
    };
  };

  imports = [
    # Conditionally import the image module
    (args @ {pkgs, ...}: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix" args;
      config = lib.mkIf cfg.enable module.config;
    in
      module // {inherit config;})
  ];
}
