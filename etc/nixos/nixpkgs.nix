{ pkgs
, config
, ...
}:

{
  nixpkgs = {
    config =
      {
        # Enable unfree packages
        allowUnfree = true;

        # Non-overlay overrides
        packageOverrides = pkgs:
          {
            # See https://nixos.wiki/wiki/Cheatsheet#Customizing_Packages
            # unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
          };
      };

    overlays = [
      (import ./overlay.nix)
      # (import "${nixpkgs-mozilla}/rust-overlay.nix")
      #gitignore
    ];

  };
}
