{
  config
, pkgs
, ...
}:


let terminalemulator = "sakura";
in
{
  environment = {

    # binsh
    # blcr
    # checkConfigurationOptions
    # enableBashCompletion

    /* etc = { */
    /*   gitconfig.source = */
    /*     '' */
    /*       [difftool] */
    /*         external = diffuse */
    /*     ''; */
    /* }; */

    # extraInit
    # freetds
    # gnome3

    # keep the current route for new shell environments
    # interactiveShellInit = ". ${pkgs.gnome3.vte}/etc/profile.d/vte.sh";

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
      yim        = ''yi --keymap=vim --frontend=vty'';
      yimacs     = ''yi --keymap=emacs'';
      chshell    = ''cd ~/projects/development/circuithub/mono ; nix-shell --arg dev true'';
      git-conflicts = ''_lambda(){ git status -s | grep \\\(UU\\\|AA\\\) | sed "s/\(UU\|AA\) //"; }; _lambda''; # open vim with unmerged files
      git-branches = ''git for-each-ref --sort=-committerdate refs/heads/ --format="%(committerdate:short) %(authorname) %(refname:short)"''; # list branches by date
      git-branches-diff = ''diff --color --side-by-side --suppress-common-lines <(git for-each-ref --sort=-objectname refs/heads --format="%(committerdate:short) %(refname:strip=2) %(authorname)") <(git for-each-ref --sort=-objectname refs/remotes/origin --format="%(committerdate:short) %(refname:strip=3) %(authorname)")''; # diff with origin branches
      # config   = ''su ; cd /etc/nixos''; # TODO: how to start in /etc/nixos path?
      # upgrade  = ''sudo NIX_PATH="$NIX_PATH:unstablepkgs=${<unstablepkgs>}" nixos-rebuild switch --upgrade'';
      # upgrade  = ''sudo -E nixos-rebuild switch --upgrade -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs -I unstablepkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs'';
      # see also  [nix? alias](https://nixos.org/wiki/Howto_find_a_package_in_NixOS#Aliases)
      upgrade    = ''sudo -E nixos-rebuild switch --upgrade -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs'';
      switch     = ''sudo -E nixos-rebuild switch -I devpkgs=${config.users.users.me.home}/projects/config/nixpkgs'';
      nixos-rebuild-unstable = ''nixos-rebuild -I /root/.nix-defexpr/channels/nixos-unstable'';
      nixos-list-generations = ''nix-env --list-generations --profile /nix/var/nix/profiles/system'';
      nixq       = ''nix-env --query --available --attr-path --description | fgrep --ignore-case --color'';
      nixhq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr haskellPackages --description | fgrep --ignore-case --color''; # query haskellPackages
      nixnq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr nodePackages --description | fgrep --ignore-case --color''; # query nodePackages
      nixgq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr goPackages --description | fgrep --ignore-case --color''; # query goPackages
      nixeq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr elmPackages --description | fgrep --ignore-case --color''; # query elmPackages
      nixpq      = ''nix-env --file "<nixpkgs>" --query --available --attr-path --attr pythonPackages --description | fgrep --ignore-case --color''; # query pythonPackages
      nixgc      = ''nix-collect-garbage --delete-older-than 30d; nix-store --optimise;''; # garbage collect old stuff and optimise
      nix-roots  = ''nix-store --gc --print-roots''; # print garbage collector roots
      term       = ''${terminalemulator}'';                                     # shortcut to open a terminal
      # services shorthands (similar to upstart)
      start      = ''systemctl start'';
      stop       = ''systemctl stop'';
      restart    = ''systemctl restart'';
      status     = ''systemctl status'';
      # editor s horthands
      vi         = ''vim'';
      virecent   = ''vim `git diff HEAD~1 --relative --name-only`'';                          # open recently modified (git tracked) files
      viconflict = ''_lambda(){ vim $(git status -s | grep \\\(UU\\\|AA\\\) | sed "s/^\(UU\|AA\) //"); }; _lambda''; # open vim with unmerged files
      # virc       = ''vim ~/.vimrc'';                                            # quickly open vimrc file for editing vim settings
      vienv      = ''vim /etc/nixos/environment.nix'';                             # quickly open environment.nix
      vivi       = ''vim /etc/nixos/vim-configuration.nix'';                       # quickly open vim-configuration.nix
      vipkgs     = ''vim $HOME/.config/nixpkgs'';                                  # quickly open ~/.config/nixpkgs
      vioverlays = ''vim $HOME/.config/nixpkgs/overlays/all.nix'';                 # quickly open ~/.config/nixpkgs/overlays/all.nix
      /* viwin      = ''_lambda(){ gnome-terminal -x sh -c "vim $1"; }; _lambda''; # open vim in a new gnome-terminal window */
      /* vifind     = ''_lambda(){ vim $(find -type f -name "$@"); }; _lambda'';   # open vim with the file in the search result */
      vigrep     = ''_lambda(){ vim $(ag $@ -l); }; _lambda'';                     # open vim with the files containing the search string
      yirecent   = ''yi `git diff HEAD~1 --relative --name-only`'';                # open recently modified (git tracked) files
      yifind     = ''_lambda(){ yi $(find -type f -name "$@"); }; _lambda'';       # open yi with the file in the search result
      vifind     =
        # open vim with the file in the search result
        ''
        _lambda(){
          local f=$(find -name "$@")
          if [ -d "$f" ] ; then
            vim $(find -type d -name "$@")
          elif [ -n "$f" ] ; then
            vim $(find -type f -name "$@")
          else
            echo "Could not find \"$@\""
          fi
        }; _lambda'';
      findexec =
        ''
        _lambda(){
          echo "About to run: find . -type f -exec" "$@" "{} \;"
          read
          (find . -type f -exec "$@" {} \;)
        }; _lambda'';
      findsed =
        ''
        _lambda(){
          echo "About to run: find . -type f -exec sed -ri" "$@" "{} \;"
          read
          (find . -type f -exec sed -ri "$@" {} \;)
        }; _lambda'';
      simplesed =
        ''
        _lambda(){
          echo "About to run: find . -type f -exec sed -ri s/$1/$2/g" "{} \;"
          read
          (find . -type f -exec sed -ri s/$1/$2/g {} \;)
        }; _lambda'';
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
      git-unpushed-branches = ''git log --branches --not --remotes --simplify-by-decoration --decorate --oneline'';
      clip = ''xclip -selection clipboard'';
      simpledate = ''date +%Y-%m-%d'';
      battery = ''cat /sys/class/power_supply/BAT0/capacity'';

      # temporary helpers (fix problems)
      disablegpe16 = ''echo "disable" > /sys/firmware/acpi/interrupts/gpe16'';
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


      # Aesthetics
      gnome3.gtk
      # oxygen-gtk2
      # oxygen-gtk3
      # kde4.oxygen_icons
      # gtk-engine-murrine

      # Security
      gnome3.gnome_keyring

      # Hardware control
      light
    ];

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
      ME_CHANNELS = "${config.users.users.me.home}/.nix-defexpr/channels";
    };

    # wvdial
    # x11Packages

  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
