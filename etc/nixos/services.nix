{
  config
, pkgs
, ...
}:

{
  services =
    {
      /* ntpd pauses for a long time during shutdown which is very annoying */
      /* chrony may be the alternative to use (todo) */
      /* ntp.enable = true;         # Keep system clock updated */
      /* services.chrony.enable = true; */
      timesyncd.enable = true;

      #Interplanetary File System
      ipfs =
        {
          # Does this work well with kernel 4.10?
          # enable = true;
          emptyRepo = true;
        };

      # Enable the X11 windowing system.
      xserver =
        {
          autorun = true; # default is true
          enable = true;
          layout = "us";

          # Key bindings
          # * Disable capslock (useful for switching caps to a mod key in xmonad/elsewhere)
          # xkbOptions = "ctrl:nocaps";
          # * Terminate current session using ctrl + alt + backspace (usefull on macs)
          # * Make capslock into an additional escape key
          xkbOptions = "terminate:ctrl_alt_bksp, caps:escape";

          # Enable XMonad Desktop Environment. (Optional)
          windowManager =
            {
              default = "xmonad";
              xmonad =
                {
                  enable = true; 
                  # Note that xmonad-extras seems to be broken frequently, so use xmonad-contrib alone
                  /* enableContribAndExtras = true; */
                  extraPackages = haskellPackages:
                    [
                      /* haskellPackages.taffybar #todo */
                      haskellPackages.xmonad-contrib
                    ];
                };
            };

          # Set the desktop manager to none so that it doesn't default to xterm sometimes
          desktopManager =
            {
              default = "none";
            };
          displayManager =
            {
              slim.enable = true;
              # auto = {
                # enable = true;
                # user = "rehno";
              # };
            };

          # Screen
          # virtualScreen = { x = 2880 ; y = 1800; };
          # resolutions = { x = 2880 ; y = 1800; };

          # Compose key
          # xkbOptions = "compose:caps";
        };

      # Entertainment
      /* TODO: Unfortunately I can't get it to work well with spotify */
      /* mopidy = */
      /*   { */
      /*     enable = true; */
      /*     extensionPackages = */
      /*       [ */
      /*         pkgs.mopidy-spotify */
      /*         pkgs.mopidy-mopify */
      /*         pkgs.mopidy-moped */
      /*         https://github.com/jaedb/iris */
      /*         https://github.com/pimusicbox/mopidy-musicbox-webclient */
      /*       ]; */
      /*     configuration = */
      /*       let username = "rehnol"; # "username"; # gitignore */
      /*           password = "dY45sAets"; # "password"; # gitignore */
      /*       in */
      /*         '' */
      /*         [spotify] */
      /*         username = ${username} */
      /*         password = ${password} */
      /*         ''; */
      /*   }; */

      # Enable teamviewer :( # (don't do it!)
      # teamviewer.enable = true;

      /*
      actkbd =
        {
          enable = true;
          bindings =
          [
            # Remap menu key to cheatsheet for now
            # { keys = [ 135 ]; events = [ "key" "rep" ]; command = "eog ${config.users.users.me.home}/cheatsheets/workman.png"; }
            { keys = [ 134 ]; events = [ "key" "rep" ]; command = "eog ${config.users.users.me.home}/cheatsheets/workman.png"; }
            { keys = [ 21 ]; events = [ "key" "rep" ]; command = "eog ${config.users.users.me.home}/cheatsheets/workman.png"; }
            { keys = [ 64 39 ]; events = [ "key" "rep" ]; command = "gnome-screenshot -i"; }
          ];
        };
      */
      # Activate these if you're not using xmonad to control media keys
      # To find keyboard devices:
      #   $ cat /proc/bus/input/devices 
      # or alternatively: 
      #   $ ls /dev/input/by-id
      # To find key stroke codes:
      #   $ actkbd -s -d /dev/input/by-id/$mykbd
      # actkbd = {
      #   enable = true;
      #   bindings = [
      #     # Cheatsheets
      #     { keys = [ 127 ]; events = [ "key" "rep" ]; command = "${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png"; }
      #     { keys = [ 118 ]; events = [ "key" "rep" ]; command = "${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png"; }
      #     { keys = [ 58 ]; events = [ "key" "rep" ]; command = "${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png"; }
      #     { keys = [ 126 ]; events = [ "key" "rep" ]; command = "${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png"; }
      #     { keys = [ 60 ]; events = [ "key" "rep" ]; command = "${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png"; }
      #     { keys = [ 64 ]; events = [ "key" "rep" ]; command = "bash -c '${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png'"; }
      #   ];
      # };

      # Security
      gnome3.gnome-keyring.enable = true; # gnome's default keyring (TODO: better description)
      # startGnuPGAgent = true;           # alternative to gnome-keyring (TODO: better security, less convenience?)

      # Development
      hoogle =
        {
          enable = true;
          packages = haskellPackages: with haskellPackages; [ text ]; # TODO: what goes here?
        };

      # Editors
      emacs.enable = true;
    };
}
