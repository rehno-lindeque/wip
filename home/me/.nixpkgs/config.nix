{ pkgs
, ... 
}:

# Use
#   $ nix-env -u
# to update

let
  # devpkgs = import <devpkgs> {}; 
  # yipkgs = pkgs.haskell.packages.ghc7101.ghcWithPackages 
  #            (ps: with ps; [
  #                yi
  #                yi-language  # collection of language plugins for yi
  #                yi-contrib # collection of usefull plugins
  #            ]);
  stdenv = pkgs.stdenv;
in
{
  allowUnfree = true;

  # packageOverrides = super: {
  #   # yi-custom = import ./yi-custom.nix { pkgs = devpkgs; };
  #   heroku = devpkgs.heroku;
  # };

  # environment = {
  #   systemPackages = with pkgs ; [
  #     yi-custom
  #   ];
  # };

  # nix.nixPath = [
  #   # Default nix paths
  #   "/nix/var/nix/profiles/per-user/root/channels/nixos"
  #   "nixos-config=/etc/nixos/configuration.nix"
  #   "/nix/var/nix/profiles/per-user/root/channels"
  #   # Added
  #   "unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs"
  #   "devpkgs=/home/rehno/projects/config/nixpkgs"
  # ];

  /* elmEnv = stdenv.mkDerivation { */
  /*   name = "elm-env"; */
  /*   buildInputs = [ */
  /*     pkgs.elmPackages.elm-compiler */
  /*     pkgs.elmPackages.elm-make */
  /*     pkgs.elmPackages.elm-package */
  /*     # pkgs.elmPackages.elm-reactor */
  /*   ]; */
  /* }; */

}
