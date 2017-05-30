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
  peek = pkgs.callPackage ./peek.nix {};
  moonscript = pkgs.callPackage ./moonscript.nix {};
  gifine = pkgs.callPackage ./gifine.nix { inherit moonscript; };
in
{
  allowUnfree = true;
  services.emacs.enable = true;
  packageOverrides = super: with super; rec {

    inherit (import ./yi-custom.nix { inherit pkgs; }) yi-custom;

    /* spotify = */
    /*     pkgs.callPackage */
    /*       ( pkgs.fetchurl */
    /*         { */
    /*           url = https://github.com/thall/nixpkgs/blob/9069aafecc104fc2dc39157b32f59eddaf957a51/pkgs/applications/audio/spotify/default.nix; */
    /*           sha256 = "1l0ppsps3rz63854i3cfsy4mnkin4pg44fqxx32ykl30ybqzf4y5"; */
    /*         } */
    /*       ) */
    /*       {}; */

    spotify = pkgs.lib.overrideDerivation super.spotify
      (let version = "1.0.47.13.gd8e05b1f-47";
        in
          (attrs: {
            name = "spotify-${version}";
            src =
              fetchurl {
                url = "http://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_${version}_amd64.deb";
                sha256 = "0079vq2nw07795jyqrjv68sc0vqjy6abjh6jjd5cg3hqlxdf4ckz";
              };
          })
      );

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

    # Maintenance environment
    # Enter an environment like this:
    #
    #   $ load-env-maintenance
    #
    maintenanceEnv = myEnvFun
      {
        name = "maintenance";
        buildInputs = with python34Packages; [
          lm_sensors # temperature
          usbutils   # list usb devices
          powertop   # power/battery management analysis and advice
          libsysfs   # list options that are set for a loaded kernel module
                     # * https://wiki.archlinux.org/index.php/kernel_modules#Obtaining_information
          radeontop  # investigate gpu usage
          bmon       # monitor network traffic
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

          # Identity
          keybase

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
          /* yi-custom */
          # sublime3

          # Development and ops
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
          # awscli        # command-line interface for AWS
          # ec2_api_tools
          # inotify-tools
          # heroku
          # xorg.xev  # A utility for looking up X keycodes and other input event codes
          # pgadmin
          patchelf
          sshuttle    # Quick zero-setup VPN over ssh

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
          mopidy
          spotify # TODO: replace this with mopidy
          vlc

          # Artistic
          gimp

          # File browsers
          gnome3.eog

          # Screen capture
          gnome3.gnome-screenshot
          # peek
          # gifine

          # Working environments
          maintenanceEnv

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
