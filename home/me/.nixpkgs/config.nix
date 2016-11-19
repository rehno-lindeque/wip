{ pkgs
, ...
}:

# Use
#   $ nix-env -u
# to update

let
  # devpkgs = import <devpkgs> {}; 
  stdenv = pkgs.stdenv;
  # TODO: Remove
  /* inherit (with pkgs; import ./eth-env.nix { inherit pkgs stdenv fetchFromGitHub fetchurl unzip makeWrapper makeDesktopItem buildEnv myEnvFun; }) ethEnv; #gitignore */
  inherit (pkgs.callPackage ./eth-env.nix {}) ethEnv ethClassicEnv;
in
{
  allowUnfree = true;
  services.emacs.enable = true;
  packageOverrides = super: with super; rec {

    inherit (import ./yi-custom.nix { inherit pkgs; }) yi-custom;

    # Work environments
    # Enter an environment like this:
    #
    #   $ load-env-analysis
    #
    analysisEnv = myEnvFun
      {
        name = "analysis";
        buildInputs = with python34Packages; [
          python34
          numpy
          toolz
          ipython
          numpy
          scipy
          matplotlib
          pandas
          # cvxopt
        ];
      };

    # My non-system packages
    # Install and update using:
    #
    #   $ nix-env -i me-packages
    #
    mycli = pkgs.pythonPackages.mycli;    # command-line interface for MySQL

    all = with pkgs; buildEnv {  # pkgs is your overriden set of packages itself
      name = "me-packages";
      paths =
        [
          # Private #gitignore
          # ethEnv    #gitignore
          # ethClassicEnv    #gitignore

          # System tools
          # ncdu               # Disk usage analyzer (ncurses ui)
          # powertop         # Analyze laptop power consumption
          # pciutils         # List PCI devices using lspci
          # unrar              # Extract files from .rar
          zip                # Create .zip archives
          # tree               # Directory listings in tree format

          # Web
          torbrowser
          # ipfs
          # dropbox
          # dropbox-cli

          # Communication
          # xchat
          # hipchat
          # slack # todo
          # irssi

          # Text editors
          # * see ~/.nixpkgs/yi.nix; a vim + emacs alternative for haskellers
          # * see vim-configuration.nix; for coders in motion
          # * see emacs-configuration.nix; the famous structured editor, emacs understands the parse structure of your favourite programming language
          yi-custom
          # sublime3

          # Development tools
          nixops
          # gitAndTools.hub
          # haskellPackages.pandoc
          # Python tools need a work-around to be installed in this way
          # (
          #   with pythonPackages;
          #   [
          #     mycli     # command-line interface for MySQL
          #     # pgcli   # command-line interface for PostgreSQL
          #   ]
          # )
          # awscli    # command-line interface for AWS
          # ec2_api_tools
          # inotify-tools
          # heroku

          # Electronics design automation
          kicad

          # Data science
          gnuplot
          # maxima
          # octave
          # ihaskell
          # analysisEnv

          # Emulators
          # wine

          # Media players
          spotify
          vlc

          # Artistic
          gimp

          # File browsers
          gnome3.eog

          # Screen capture
          gnome3.gnome-screenshot

          # Uncategorized
          /* dropbox-cli */
          /* file-roller */
          /* firefox */
          /* lynx */
          /* gimp */
          /* glxinfo */
          /* inkscape */
          /* kicad */
          /* lame */
          /* libressl */
          /* lsof */
          /* mysql-workbench */
          /* nodejs */
          /* pcre */
          /* python */
          /* rtorrent */
          /* scrot */
          /* shotwell */
          /* skype */
          /* zlib */
          /* zlib-static */
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

}
