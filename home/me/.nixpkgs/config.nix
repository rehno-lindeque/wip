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
  packageOverrides = super: with super; {
    all = with pkgs; buildEnv {  # pkgs is your overriden set of packages itself
      name = "me-packages";
      paths = [
        # System tools
        ncdu             # Disk usage analyzer (ncurses ui)
        powertop         # Analyze laptop power consumption
        pciutils         # List PCI devices using lspci

        # Web
        torbrowser
        # dropbox
        # dropbox-cli

        # Communication
        # xchat
        # hipchat
        # slack # todo

        # Layout
        # xmonad-with-packages             # Ultra-customizable (haskell) tiling window manager 
        # (Needed for compiling .xmonad/xmonad.hs) 
        (
          with haskellPackages;
          [
            xmonad
            xmonad-contrib
            xmonad-extras
            xmonad-screenshot
            xmobar
          ]
        )

        # Development tools
        # gitAndTools.hub
        # haskellPackages.pandoc
        pythonPackages.mycli
        (
          with elmPackages;
          [
            elm
            elm-compiler
            elm-make
            elm-package
            elm-reactor
          ]
        )
        awscli                        # command-line interface for AWS
        # mycli                       # command-line interface for MySQL
        # pgcli                       # command-line interface for PostgreSQL
        heroku

        # Data science
        gnuplot
        # maxima
        # octave
        ihaskell
        (
          with pythonPackages;
          [
            ipython
            numpy
            scipy
            matplotlib
            cvxopt
          ]
        )

        # Media players
        spotify
        vlc
      ];
    };
  };

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
