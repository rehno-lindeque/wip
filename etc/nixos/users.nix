{
  config
, pkgs
, ... 
}:

{
  # User account.
  # * Set a password using
  #   $ useradd -m $ME ; passwd $ME
  users =
   {
      # defaultUserShell = "/run/current-system/sw/bin/gnome-terminal";
      users =
        {
          # Limited sandbox user
          #sandy = {
          #  group = "nogroup";
          #  isNormalUser = true;
          #  createHome = true;
          #  extraGroups = [];
          #  isSystemUser = false;
          #  packages = with pkgs; [
          #    # Horrible proprietary crap
          #    striata-reader-env
          #  ];
          #};

          me =
            {
              group = "users";
              uid = 1005;
              createHome = true;
              home = "/home/${config.users.users.me.name}";
              extraGroups =
                [
                  "wheel"          # TODO: allows your user to access stored passwords?
                                   # * you need wheel in order to use sudo for example
                  "video"          # ?
                  "scanner"        # Group created by hardware.sane
                  # "keyboard"     # Used by (custom) actkbd user service
                  "networkmanager" # Needed to allow connecting to the network
                  "mysql"          # Allows you to use the running mysql service via your user (usefull for software development)
                                   # * you will see that the /var/mysql/* files that are created belongs to the mysql user & group
                  # "postgres"       # Allows you to use the running postgres service via your user (usefull for software development)
                  # "psql"           # Postgres sql
                  # "plugdev"        # Access external storage devices
                  "git"            # Access to all git repositories
                  # "wireshark"      # Permission to capture with wireshark
                ];
              isSystemUser = false;
              useDefaultShell = true;
              # TODO: remove - there's probably no reason to put our own pub key in the authorized keys
              # openssh.authorizedKeys.keyFiles = [ "${config.users.users.me.home}/.ssh/id_rsa.pub" ];
              packages = with pkgs; [
                # Terminal emulators (choose one)
                # gnome3.gnome_terminal
                sakura
                # termite

                # System tools
                # ncdu               # Disk usage analyzer (ncurses ui)
                # powertop         # Analyze laptop power consumption
                # pciutils         # List PCI devices using lspci
                # unrar              # Extract files from .rar
                zip                # Create .zip archives
                # btrfsProgs
                # tree               # Directory listings in tree format
                kbfs                # Keybase filesystem
                # xorg.luit-2_x
                nix-top
                nix-du
                # appimage-run
                nixos-generators

                # Identity
                keybase
                gnupg

                # Crypto
                # daedalus
                # sss-cli
                # mnemonicode
                # ssss
                # paperkey

                # Networking
                ipfs
                # ipfs-swarm-key-gen
                # ipfs-migrator
                # trickle
                # networkmanager_strongswan        # Connect to ipsec VPN with strongswan key exchange

                # Web
                torbrowser
                # ipfs
                # dropbox
                # dropbox-cli
                keybase-gui
                firefox
                google-chrome

                # Communication
                # xchat
                # hipchat
                # slack # todo
                # irssi
                zoom-us

                # Productivity
                dmenu                            # execute programs from a top-level menu
                xclip                            # copy to your clipboard from the terminal
                dmenu                            # execute programs from a top-level menu
                haskellPackages.yeganesh         # display popular selections in dmenu first # TODO: haskellPackages-custom
                # tmux                           # use multiple terminals inside one terminal (like xmonad for your terminal)
                # vifm                           # file manager with vi-like keybindings
                # tree                           # show a directory tree (like ls -R, but prettier)
                # feh                            # quickly preview image files (I'm using this with actkbd to display cheatsheets)
                flameshot                        # quick image/screenshot annotation tool
                                                 # TODO: add to dbus.packages and possibly extraGSettingsOverrides
                simplescreenrecorder             # record your screen
                xosd                             # display text overlay over the screen
                xorg.xmodmap                     # modify keyboard layout on the fly
                tldr                             # summaries of man pages

                # Configuration
                # gnome3.dconf
                gnome3.gnome_settings_daemon
                # nix-prefetch-github

                # Development dependencies
                ctags       # quick way to browse symbols (seems to collide with emacs ctags in tagbar at the moment though, I had to nix-env -i ctags)
                # ghc
                ghc
                elfutils    # linker, assembler, strip, etc (elfutils is a replacement for the older binutils)
                # zlib        # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs
                # zlibStatic # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs
                cabal2nix

                # Editors
                me-vim
                # sublime3
                # yi
                # me-yi
                # kakoune

                # Software development
                gitFull                       # the most popular version control system
                                              # * if you don't want to pull in so many dependencies you can use
                git-crypt
                # gitAndTools.hub
                # tig                         # text-mode browser/interactive commit tool for git 
                diffuse                       # usefull for doing graphical diffs via `git difftool`
                                              # * see also (......TODO difftool config....)
                # heroku-beta
                nixops
                # haskellPackages.pandoc
                # awscli        # command-line interface for AWS
                # ec2_api_tools
                # inotify-tools
                # heroku
                # xorg.xev  # A utility for looking up X keycodes and other input event codes
                patchelf
                # sshuttle    # Quick zero-setup VPN over ssh
                # git-crypt
                # sqlcrush
                # nix-diff-drv
                # teamviewer
                # insomnia

                # Hardware development
                teensyduino

                # Database tools
                # pgadmin
                # diwata

                # File browsers
                gnome3.nautilus
                gnome3.eog

                # Screen capture
                # gnome3.gnome-screenshot
                # peek
                # gifine

                # Electronics design automation
                # kicad

                # Data science
                gnuplot
                # maxima
                # octave
                # ihaskell
                # analysisEnv

                # Emulators
                # wine

                # Media players
                # mopidy
                vlc
                spotify # TODO: replace with mopidy

                # Artistic
                gimp
                # blender

                # Shell
                # fish           # modern featureful shell

                # Input
                # xcape        # allow modifier keys (ctrl / shift / alt / etc) to be used like regular keys (e.g. escape)
                #              # * In my configuration I was thinking of remap capslock to mod1 (which is usually alt) and then allow it to be used as escape 
                #              #   (for easy vim mode switching)

                # Office
                # simple-scan
                # gnumeric
                # pdfshuffler
                # xsane

                # Aesthetics
                hicolor_icon_theme    # Seems to be desired by some gnome or gtk applications (syncthing-gtk)?

                # TODO: investigate
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
                # firefox
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
                # ruby
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
        };
    };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
