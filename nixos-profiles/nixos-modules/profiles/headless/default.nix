flake: {
  config,
  lib,
  ...
}: let
  cfg = config.profiles.headless;
in {
  options = with lib; {
    profiles.headless = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable a configuration profile including common config used on headless machines (such as Amazon EC2 instances).
          Disables sound, vesa, serial consoles, emergency mode, grub splash images and configures the kernel to reboot automatically on panic.        '';
      };
    };
  };

  imports = [
    # Conditionally import the profile module
    (args: let
      module = import "${flake.inputs.nixpkgs}/nixos/modules/profiles/headless.nix" args;
      config = lib.mkIf cfg.enable module;
    in {inherit config;})
  ];
}
