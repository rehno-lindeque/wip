{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.personalized;
in {
  options = with lib; {
    profiles.personalized = {
      enable = mkEnableOption ''
        Whether to enable my personal configuration profile, generate my user, home directory etc
      '';
      enableSoftware = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to include software packages and services that I use somewhat frequently
        '';
      };
      enableProblematicSoftware = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to include non-essential binary packages or packages and services that occasionally have broken download links or other miscelaneous problems
        '';
      };
      enableHome = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to include home manager configuration
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Set a password using
    # passwd me
    users.users.me = rec {
      name = "me";
      description = "Rehno Lindeque";
      group = "users";
      uid = 1005;
      createHome = true;
      home = "/home/${name}";
      extraGroups = [
        # Need in order to use sudo etc
        "wheel"

        # Group created by hardware.sane for scanners
        # "scanner"

        # Used by (custom) actkbd user service
        # "keyboard"

        # Needed to allow connecting to the network
        # "networkmanager"

        # Allows you to use the running mysql service via your user (usefull for software development)
        # You will see that the /var/mysql/* files that are created belongs to the mysql user & group
        # "mysql"

        # Allows you to use the running postgres service via your user (usefull for software development)
        # "postgres"

        # Postgres sql
        # "psql"

        # Access external storage devices
        # "plugdev"

        # Access to all git repositories
        # "git"

        # Permission to capture with wireshark
        # "wireshark"

        # Permission to interact with the docker daemon (Docker group membership is effectively equivalent to being root!)
        # "docker"

        # Modify files owned by nginx
        # "nginx"

        # Access ipfs data dir (seemingly needed for pinning files)
        # "ipfs"
      ];
      isNormalUser = true;
      useDefaultShell = true;
      packages = with pkgs;
      # Terminal emulators (choose one)
        lib.optionals cfg.enableSoftware [
          # gnome3.gnome_terminal
          # sakura
          # termite
          # st
        ]
        # System tools
        ++ lib.optionals cfg.enableSoftware [
          # unrar
          # zip
          # btrfsProgs
          # xorg.luit-2_x
          nix-output-monitor
          nix-top
          # nix-du
          # appimage-run
          # nixos-generators
          nix-template

          # Disk usage analyzer (ncurses ui)
          # ncdu

          # Analyze laptop power consumption
          # powertop

          # Directory listings in tree format
          # tree

          # Keybase filesystem
          # kbfs

          # List PCI devices using lspci
          # pciutils
        ]
        # Identity
        ++ lib.optionals cfg.enableSoftware [
          keybase
          # keybase-gui
          # gnupg
        ]
        # Crypto
        ++ lib.optionals cfg.enableSoftware [
          # daedalus
          # sss-cli
          # mnemonicode
          # mnemonic
          # ssss
          # paperkey
          ledger-live-desktop
        ]
        # Security
        ++ lib.optionals cfg.enableSoftware [
          pass
        ]
        # Networking
        ++ lib.optionals cfg.enableSoftware [
          # ipfs
          # ipfs-swarm-key-gen
          # ipfs-migrator
          # trickle
        ]
        # Web
        ++ lib.optionals cfg.enableSoftware [
          firefox
          google-chrome
          brave
          # tor-browser-bundle-bin
          # dropbox
          # dropbox-cli
        ]
        # Communication
        ++ lib.optionals cfg.enableProblematicSoftware [
          zoom-us
        ]
        ++ lib.optionals cfg.enableSoftware [
          # xchat
          # hipchat
          # slack
          # irssi
          # signal-desktop
        ]
        # Productivity
        ++ lib.optionals cfg.enableSoftware [
          # tmux
          # bind

          # JSON querying & pretty printing
          jq

          # Copy to your clipboard from the terminal
          # xclip

          # File manager with vi-like keybindings
          # vifm

          # Show a directory tree (like ls -R, but prettier)
          # tree

          # Quickly preview image files (I was using this with actkbd to display cheatsheets)
          # feh

          # Display text overlay over the screen
          # xosd

          # Summaries of man pages
          # tldr

          # Modify keyboard layout on the fly
          xorg.xmodmap

          # Execute programs from a top-level menu
          # dmenu
        ]
        # Configuration
        ++ lib.optionals cfg.enableSoftware [
          # gnome3.dconf
          gnome.gnome-settings-daemon
          # nix-prefetch-github
        ]
        # Development dependencies
        ++ lib.optionals cfg.enableSoftware [
          # cabal2nix

          # Quick way to browse symbols (seems to collide with emacs ctags in tagbar at the moment though, I had to nix-env -i ctags)
          # ctags

          # Linker, assembler, strip, etc (elfutils is a replacement for the older binutils)
          elfutils
        ]
        # Editors
        ++ lib.optionals cfg.enableSoftware [
          # me-vim
          # me-neovim
          # sublime3
          # yi
          # me-yi
          # kakoune
        ]
        # Software development
        ++ lib.optionals cfg.enableSoftware [
          # git-crypt
          # heroku-beta
          # nixops
          # haskellPackages.pandoc
          # ec2_api_tools
          # inotify-tools
          # heroku
          patchelf
          # git-crypt
          # nix-diff-drv
          # teamviewer
          # insomnia
          # remmina

          # Text-mode browser/interactive commit tool for git
          # tig

          # TODO: fix
          # diffuse

          # A utility for looking up X keycodes and other input event codes
          # xorg.xev

          # Command-line interface for AWS
          # awscli

          # Quick zero-setup VPN over ssh
          # sshuttle
        ]
        # Hardware development
        ++ lib.optionals cfg.enableSoftware [
          # teensyduino
        ]
        # Database tools
        ++ lib.optionals cfg.enableSoftware [
          # pgadmin
          # dbeaver
          # diwata
          # sqlcrush
        ]
        # File browsers
        ++ lib.optionals cfg.enableSoftware [
          gnome3.nautilus
          gnome3.eog
        ]
        # Screen / Media capture
        ++ lib.optionals cfg.enableSoftware [
          # gnome3.gnome-screenshot
          # peek
          # gifine
          # youtube-dl
          # simplescreenrecorder

          # Record the terminal similar to asciinema
          # termtosvg

          # TODO: Add to dbus.packages and possibly extraGSettingsOverrides
          flameshot
        ]
        # Electronics design automation
        ++ lib.optionals cfg.enableSoftware [
          # kicad
        ]
        # Data science
        ++ lib.optionals cfg.enableSoftware [
          # gnuplot
          # maxima
          # octave
          # ihaskell
          # analysisEnv
        ]
        # Emulators
        ++ lib.optionals cfg.enableSoftware [
          # wine
        ]
        # Media players
        ++ lib.optionals cfg.enableProblematicSoftware [
          # TODO: Replace with mopidy one day
          spotify
        ]
        ++ lib.optionals cfg.enableSoftware [
          # mopidy
          # vlc

          # Pulse audio mixer ui
          pavucontrol
        ]
        # Artistic
        ++ lib.optionals cfg.enableSoftware [
          # gimp
          # blender
          # inkscape
        ]
        # Shell
        ++ lib.optionals cfg.enableSoftware [
          # fish
        ]
        # Input
        ++ lib.optionals cfg.enableSoftware [
          # Allow modifier keys (ctrl / shift / alt / etc) to be used like regular keys (e.g. escape)
          # In my configuration I'd been thinking of remapping capslock to mod1 (which is usually alt) and then allow it to be used as escape
          # (for easy vim mode switching)
          # xcape
        ]
        # Office
        ++ lib.optionals cfg.enableSoftware [
          # simple-scan
          # gnumeric
          # pdfarranger
          # xsane
          # okular
          # rotki
        ]
        # Aesthetics
        ++ lib.optionals cfg.enableSoftware [
          # Seems to be helpful for some gnome or gtk applications (syncthing-gtk)?
          # hicolor_icon_theme
        ]
        # Uncategorized
        ++ lib.optionals cfg.enableSoftware [
          # terminator
          # mpd
          # ncmpcpp
          # gmrun
          # trayer
          # dzen2
          # pv
          # lsof
          # libreoffice
          # htop
          # xscreensaver
          # arandr autorandr
          # alsaLib alsaPlugins alsaUtils
          # transmission
          # unrar
          # pavucontrol
          # chromium flashplayer
          # evince
          # ppp
          # cpufrequtils
          # file
          # htop
          # feh
          # mutt offlineimap
          # keychain
          # zsh
          # cmake
          # gcc
          # gdb
          # gimp
          # gitAndTools.gitFull
          # gnupg
          # gnupg1
          # gnumake
          # gperf
          # imagemagick
          # lsof
          # man
          # netcat
          # nmap
          # parted
          # pythonFull
          # stdmanpages
          # tcpdump
          # units
          # unrar
          # wget
          # zip
          # conkeror
          # scrot
          # unetbootin
          # wine
          # wireshark
          # xorg.xkill
          # xpdf
          # xulrunner
          # stalonetray
          # wpa_supplicant_gui
          # xfontsel
          # xlibs.xev
          # xlibs.xinput
          # xlibs.xmessage
          # xlibs.xmodmap
        ];
    };

    home-manager = lib.mkIf cfg.enableHome {
      users.me = {
        programs = {
          git = {
            enable = lib.mkDefault cfg.enableSoftware;
            userEmail = "rehno.lindeque@gmail.com";
            userName = "Rehno Lindeque";
          };
        };
      };
    };

    services = {
    };

    # Approximate location used with redshift
    location = {
      latitude = 42.4072;
      longitude = -71.3824;
    };
  };
}
