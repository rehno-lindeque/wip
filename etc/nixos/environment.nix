{ config
, pkgs
, ... 
}:

let # devpkgs = import <devpkgs> {}; 
    ghc = pkgs.haskell.packages.ghc7101;
    withHoogle = pkgs.haskell.lib.withHoogle;
    ghcEnv = # withHoogle 
             ( ghc.ghcWithPackages
               ( self: with self; [
                   /* usefull for compiling miscelaneous haskell things */
                   cabal-install
                   zlib
                   /* type-lookup etc for various editors */
                   # ghc-mod-dev
                   ghc-mod
                   /* search plugins for various editors */
                   # hoogle
                   hoogle-index
                   # Hayoo
                   # hayoo-cli
                   /* needed for stylish plugins (vim) */
                   stylish-haskell
                   /* needed for emacs haskell plugins */
                   hasktags
                   # vim haskell tags
                   # lushtags # needed?
                   # haskell-docs
                   present
                   /* needed for vim tagbar */
                   hscope
                   codex
                   /* needed for xmonad */
                   xmonad
                   xmonad-contrib
                   xmonad-extras
                 ])
               );
in
{
  environment = {

    # binsh
    # blcr
    # checkConfigurationOptions
    # enableBashCompletion
    # etc
    # extraInit
    # freetds
    # gnome3

    # keep the current route for new shell environments
    interactiveShellInit = ". ${pkgs.gnome3.vte}/etc/profile.d/vte.sh";

    # kdePackages
    # loginShellInit
    # nix
    # noXlibs
    # pathsToLink
    # profileRelativeEnvVars
    # profiles
    # promptInit
    # sessionVariables

    shellAliases = {
      yim = "yi --as=vim";
      yimacs = "yi --as=emacs";
      # config = "su ; cd /etc/nixos"; # TODO: how to start in /etc/nixos path?
      # upgrade = "sudo NIX_PATH=\"$NIX_PATH:unstablepkgs=${<unstablepkgs>}\" nixos-rebuild switch --upgrade";
      # upgrade = "sudo -E nixos-rebuild switch --upgrade -I devpkgs=/home/rehno/projects/config/nixpkgs -I unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs";
      # see also [nix? alias](https://nixos.org/wiki/Howto_find_a_package_in_NixOS#Aliases)
      upgrade = "sudo -E nixos-rebuild switch --upgrade -I devpkgs=/home/rehno/projects/config/nixpkgs";
      nixq = "nix-env --query --available --attr-path --description | fgrep --ignore-case --color";
      nixhq = "nix-env --file \"<unstablepkgs>\" --query --available --attr-path --attr haskellPackages --description | fgrep --ignore-case --color"; # query haskellPackages
      nixnq = "nix-env --file \"<unstablepkgs>\" --query --available --attr-path --attr nodePackages    --description | fgrep --ignore-case --color"; # query nodePackages
      nixgc = "nix-collect-garbage --delete-older-than 30d; nix-store --optimise;"; # garbage collect old stuff and optimise
      # editor shorthands
      vimrecent = "vim `git diff HEAD~1 --name-only`"; # open recently modified (git tracked) files
      vimrc = "vim ~/.vimrc"; # quickly open vimrc file for editing vim settings
      vimenv = "vim /etc/nixos/environment.nix"; # quickly open vimrc file for editing vim settings
    };

    # shellInit
    # shells

    # List packages installed in system profile. 
    # * Search for packages by name:
    #   $ nix-env -qaP | grep wget
    # * To get access to new haskellPackages, evil-god-state, etc... use the unstable channel (see the top of this file)
    systemPackages = with pkgs ; [
      # Basics
      wget
      # curl
      pstree
      unzip
      silver-searcher     # ag command lets you grep very fast and can be used in vim

      # Nix packaging
      nix-repl
      nix-prefetch-scripts # use this to generate sha for github packages while building nix expressions using pkgs.fetchFromGitHub
      # nox                # an interactive installer for nix (it is slightly more newbie-friendly than nix-env)
                           # * I don't use this right now because it seems a little bit buggy at the moment
      pluginnames2nix      # utility to generate nix derivations for vim (see nixpkgs.nix)

      # Shell
      # fish           # modern featureful shell

      # Input
      # xcape        # allow modifier keys (ctrl / shift / alt / etc) to be used like regular keys (e.g. escape)
      #              # * In my configuration I was thinking of remap capslock to mod1 (which is usually alt) and then allow it to be used as escape 
      #              #   (for easy vim mode switching)

      # Editors 
      # * see ~/.nixpkgs/yi.nix; a vim + emacs alternative that haskellers love
      # * see vim-configuration.nix; for coders in motion 
      # * see emacs-configuration.nix; the famous structured editor, emacs understands the parse structure of your favourite programming language
      yi-custom
      sublime3

      # Development
      gitFull                       # the most popular version control system
                                    # * if you don't want to pull in so many dependencies you can use
      # tig                         # text-mode browser/interactive commit tool for git 
      diffuse                       # usefull for doing graphical diffs via `git difftool`
                                    # * see also (......TODO difftool config....)
      awscli                        # command-line interface for AWS
      mycli                         # (awesome) command-line interface for MySQL
      # pgcli                       # (awesome) command-line interface for PostgreSQL
      # elm-custom                    # elm configuration (with tweaks to make it compile)
      # elm                           # Elm compiler + tools
      elmPackages.elm-compiler

      # Terminal
      # TODO: gnome-terminal

      # Productivity
      dmenu                     # execute programs from a top-level menu
      haskellPackages.yeganesh  # display popular selections in dmenu first
      xclip                     # copy to your clipboard from the terminal 
      # tmux                    # use multiple terminals inside one terminal (like xmonad for your terminal)
      # vifm                    # file manager with vi-like keybindings
      # tree                    # show a directory tree (like ls -R, but prettier)

      # Web
      chromium

      # Communication 
      # xchat 
      hipchat
      # slack # todo

      # Layout
      # xmobar # TODO
      haskellPackages.xmonad

      # Aesthetics
      gnome3.gtk
      # oxygen-gtk2
      oxygen-gtk3
      # kde4.oxygen_icons
      # gtk-engine-murrine

      # Security
      gnome3.gnome_keyring

      # Development dependencies 
      ctags       # quick way to browse symbols (seems to collide with emacs ctags in tagbar at the moment though, I had to nix-env -i ctags)
      # ghc
      ghcEnv      # TODO: rename to ghc-custom ?
      # haskellPlatform
      elfutils    # linker, assembler, strip, etc (elfutils is a replacement for the older binutils)
      # zlib        # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs
      # zlibStatic # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs

      # Not necessary inside virtualbox:
      # acpi
      # xscreensaver
      # pmutils


      # TODO: investigate
      # terminator
      # mpd
      # ncmpcpp
      # gmrun
      # dmenu
      # trayer
      # dzen2
      # pv
      # lsof
      # libreoffice
      # htop
      # xclip
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
      # pulseaudio
      # pythonFull
      # ruby
      # stdmanpages
      # tcpdump
      # units
      # unrar
      # vlc
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
      # haskellPackages.xmonad
      # haskellPackages.xmonadContrib
      # haskellPackages.xmonadExtras
      # haskellPackages.xmobar
      # stalonetray
      # wpa_supplicant_gui
      # xfontsel
      # xlibs.xev
      # xlibs.xinput
      # xlibs.xmessage
      # xlibs.xmodmap

    ];
    # unixODBCDrivers

    variables = rec {
      # Set vim as the [standard editor](http://stackoverflow.com/a/2596835/167485) for git, xmonad and other programs
      VISUAL = "vim";
      EDITOR = VISUAL;
      # Make chrome the default browser (used by xmonad http://hackage.haskell.org/package/xmonad-contrib-0.11.4/docs/XMonad-Actions-WindowGo.html#v:raiseBrowser and other programs)
      BROWSER = "chromium-browser";
      # Helper to get to user home, even in su
      ME_HOME = "/home/rehno"; # TODO: rename to /home/me
    };

    # wvdial
    # x11Packages

  };
}

