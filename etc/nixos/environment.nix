{
  config
, pkgs
, ...
}:

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
      yim        = ''yi --as=vim'';
      yimacs     = ''yi --as=emacs'';
      # config   = ''su ; cd /etc/nixos''; # TODO: how to start in /etc/nixos path?
      # upgrade  = ''sudo NIX_PATH="$NIX_PATH:unstablepkgs=${<unstablepkgs>}" nixos-rebuild switch --upgrade'';
      # upgrade  = ''sudo -E nixos-rebuild switch --upgrade -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs -I unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs'';
      # see also  [nix? alias](https://nixos.org/wiki/Howto_find_a_package_in_NixOS#Aliases)
      upgrade    = ''sudo -E nixos-rebuild switch --upgrade -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs'';
      switch     = ''sudo -E nixos-rebuild switch -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs'';
      nixq       = ''nix-env --query --available --attr-path --description | fgrep --ignore-case --color'';
      nixhq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr haskellPackages --description | fgrep --ignore-case --color''; # query haskellPackages
      nixnq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr nodePackages --description | fgrep --ignore-case --color''; # query nodePackages
      nixgq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr goPackages --description | fgrep --ignore-case --color''; # query goPackages
      nixeq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr elmPackages --description | fgrep --ignore-case --color''; # query elmPackages
      nixgc      = ''nix-collect-garbage --delete-older-than 30d; nix-store --optimise;''; # garbage collect old stuff and optimise
      # editor s horthands
      vimrecent  = ''vim `git diff HEAD~1 --relative --name-only`'';            # open recently modified (git tracked) files
      vimrc      = ''vim ~/.vimrc'';                                            # quickly open vimrc file for editing vim settings
      vimenv     = ''vim /etc/nixos/environment.nix'';                          # quickly open environment.nix
      vimvim     = ''vim /etc/nixos/vim-configuration.nix'';                    # quickly open vim-configuration.nix
      vimpkgs    = ''vim $HOME/.nixpkgs/config.nix'';                           # quickly open ~/.nixpkgs/config.nix
      vimwin     = ''_lambda(){ gnome-terminal -x sh -c "vim $1"; }; _lambda''; # Open vim in a new gnome-terminal window
      vimfind    = ''_lambda(){ vim $(find -type f -name "$@"); }; _lambda'';    # Open vim with the file in the search result
      vimgrep    = ''_lambda(){ vim $(ag $@ -l); }; _lambda'';                  # Open vim with the files containing the search string
      diffr  =
        ''
        _lambda(){
          diff -qNr -x .git $@ | sed "s/Files\\s//g; s/\\sand//g; s/differ//g" | while read line ; do
            ${config.environment.variables.DIFFTOOL} $line
          done;
        }; _lambda'';
      diffetc    =
        ''
        diff -qNr /etc/nixos/ ${config.users.users.me.home}/projects/config/dotfiles/etc/nixos -x result | sed "s/Files\\s//g; s/\\sand//g; s/differ//g" | while read line ; do
          touch $line
          ${config.environment.variables.DIFFTOOL} $line
        done;
        '';
      diffhome   = 
        ''
        diff --unidirectional-new-file -qr ${config.users.users.me.home} ${config.users.users.me.home}/projects/config/dotfiles/home/me | while read line ; do
          echo $line
          case $line in
            Files*)
              args=`sed "s/Files\\s//g; s/\\sand//g; s/differ//g" <(echo "$line")`
              touch $args
              ${config.environment.variables.DIFFTOOL} $args
              ;;
          esac
        done
        '';
      diffroot   = 
        ''
        diff --unidirectional-new-file -qr /root ${config.users.users.me.home}/projects/config/dotfiles/home/root | while read line ; do
          echo $line
          case $line in
            Files*)
              args=`sed "s/Files\\s//g; s/\\sand//g; s/differ//g" <(echo "$line")`
              touch $args
              ${config.environment.variables.DIFFTOOL} $args
              ;;
          esac
        done
        '';
    };

    # shellInit
    # shells

    # List packages installed in system profile. 
    # * Search for packages by name:
    #   $ nix-env -qaP | grep wget
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
      # pluginnames2nix      # utility to generate nix derivations for vim (see nixpkgs.nix)
      # vim2nix      # utility to generate nix derivations for vim (see nixpkgs.nix)

      # Shell
      # fish           # modern featureful shell

      # Input
      # xcape        # allow modifier keys (ctrl / shift / alt / etc) to be used like regular keys (e.g. escape)
      #              # * In my configuration I was thinking of remap capslock to mod1 (which is usually alt) and then allow it to be used as escape 
      #              #   (for easy vim mode switching)

      # Development
      gitFull                       # the most popular version control system
                                    # * if you don't want to pull in so many dependencies you can use
      # tig                         # text-mode browser/interactive commit tool for git 
      diffuse                       # usefull for doing graphical diffs via `git difftool`
                                    # * see also (......TODO difftool config....)
      awscli                        # command-line interface for AWS
      # elm-custom                    # elm configuration (with tweaks to make it compile)
      # elm                           # Elm compiler + tools
      elmPackages.elm
      elmPackages.elm-compiler
      elmPackages.elm-make
      elmPackages.elm-package
      elmPackages.elm-reactor

      # Terminal
      gnome3.gnome_terminal

      # Productivity
      dmenu                            # execute programs from a top-level menu
      haskellPackages.yeganesh         # display popular selections in dmenu first # TODO: haskellPackages-custom
      xclip                            # copy to your clipboard from the terminal 
      # tmux                           # use multiple terminals inside one terminal (like xmonad for your terminal)
      # vifm                           # file manager with vi-like keybindings
      # tree                           # show a directory tree (like ls -R, but prettier)

      # Web
      chromium
      # Layout
      haskellPackages.xmonad # TODO: haskellPackages-custom

      # Aesthetics
      gnome3.gtk
      # oxygen-gtk2
      oxygen-gtk3
      # kde4.oxygen_icons
      # gtk-engine-murrine

      # Configuration
      gnome3.gnome_settings_daemon

      # Security
      gnome3.gnome_keyring

      # Development dependencies 
      ctags       # quick way to browse symbols (seems to collide with emacs ctags in tagbar at the moment though, I had to nix-env -i ctags)
      # ghc
      ghc-custom
      elfutils    # linker, assembler, strip, etc (elfutils is a replacement for the older binutils)
      # zlib        # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs
      # zlibStatic # useful for compiling several haskell packages e.g. elm's BuildFromSource.hs

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
    # unixODBCDrivers

    variables = rec {
      # Set vim as the [standard editor](http://stackoverflow.com/a/2596835/167485) for git, xmonad and other programs
      VISUAL  = "vim";
      EDITOR  = VISUAL;
      # Make chrome the default browser (used by xmonad http://hackage.haskell.org/package/xmonad-contrib-0.11.4/docs/XMonad-Actions-WindowGo.html#v:raiseBrowser and other programs)
      BROWSER = "chromium-browser";
      # This is not recognized by any tools, but it's used elsewhere in this config to run the appropriate diff tool
      DIFFTOOL = "diffuse";
      # Helpers to get to the primary user's username and home path, even as su
      ME = "${config.users.users.me.name}";      # this is somewhat similar to logname (except only for the primary user)
      ME_HOME = "${config.users.users.me.home}";
      ME_DOTFILES = "${config.users.users.me.home}/projects/config/dotfiles";
    };

    # wvdial
    # x11Packages

  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
