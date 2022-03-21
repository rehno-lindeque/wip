{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.common;
in {
  options = with lib; {
    profiles.common = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable my most basic configuration profile.

          Common, as in "shared configuration", but also common as in "common sense".
          That is, overly specific configuration is excluded even when shared between different systems.
          (I generally ask myself if this is something I would want on any non-graphical live disk.)
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Basic productivity
      wget
      ripgrep
      fzf
      pstree
    ];

    # Currently I always use network manager for convenience
    # (However, this is something I'm still evaluating)
    # nmtui or nmcli can be used to control network manager
    networking.networkmanager.enable = lib.mkDefault true;

    nix = {
      # There's no point to using any of these configs without flakes
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';

      # It seems common sense to use nixos official caches
      binaryCaches = [
        http://cache.nixos.org/
      ];

      binaryCachePublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    # Unfree software is a fact of life
    nixpkgs.config.allowUnfree = true;

    # Always apply the the default overlay supplied by the flake
    nixpkgs.overlays = [flake.overlay];

    # Git is somewhat essential for working with nix flakes
    programs.git.enable = lib.mkDefault true;

    # The firewall is on by default anyway, but turn it on explicitly since it's a security setting
    networking.firewall.enable = true;
  };
}
