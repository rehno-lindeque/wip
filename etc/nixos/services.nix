{
  config
, pkgs
, lib
, ...
}:

{
  # };

  services =
    {
      /* ntpd pauses for a long time during shutdown which is very annoying */
      /* chrony may be the alternative to use (todo) */
      /* ntp.enable = true;         # Keep system clock updated */
      /* services.chrony.enable = true; */
      timesyncd.enable = true;

      # Interplanetary File System
      ipfs = {
        enable = true;
        # emptyRepo = true;
        # extraConfig = {
        # };
      };

      # Identity/Key/Cloud storage management
      # TODO: 17.09
      keybase.enable = true;
      kbfs = {
        enable = true;
        mountPoint = "/keybase";
      };

      # Turn on auto-mount
      devmon.enable = true;

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
              lightdm = {
                enable = true;
                # defaultUser = config.users.users.me.name;
              };
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
      teamviewer.enable = true;

      # Activate these if you're not using xmonad to control media keys
      # To find keyboard devices:
      #   $ cat /proc/bus/input/devices
      # or alternatively: 
      #   $ ls /dev/input/by-id
      # To find key stroke codes:
      #   $ actkbd -s -d /dev/input/by-id/$mykbd
      actkbd = {
        enable = true;
        user = "me";
        extraGroups = [ "input" "audio" "leds" "messagebus" ];
        bindings =
          let
            me-home = "${config.users.users.me.home}";
            eog-bin = "${pkgs.gnome3.eog}/bin/eog";
            feh-bin = "${pkgs.feh}/bin/feh";
            workman_keyboard_layout = pkgs.fetchipfs {
              # url = "http://xahlee.info/kbd/i/layout/workman_keyboard_layout.png";
              ipfs = "QmQvAP2izzhwpiv619of7xPyXW3ucsWLhDPs4N7Z6o5kYq";
              sha256 = "09qwx8vq3cvzm2qdkk234m80mx2nal4as6iikz176c9aamlgz3aj";
            };
            dbus-mediaplayer2-identify = pkgs.writeScript "dbus-mediaplayer2-identify" ''
              #!${pkgs.stdenv.shell}
              ${pkgs.dbus}/bin/dbus-send \
                --print-reply \
                --type=method_call \
                --dest=org.freedesktop.DBus \
                /org/freedesktop/DBus \
                org.freedesktop.DBus.ListNames \
                | grep 'org.mpris.MediaPlayer2.\([^"]*\)' -o \
                | head -n 1
              '';
            dbus-mediaplayer2-send = pkgs.writeScript "dbus-mediaplayer2-send" ''
              #!${pkgs.stdenv.shell}
              ${pkgs.dbus}/bin/dbus-send --type=method_call --dest=$(${dbus-mediaplayer2-identify}) /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$1
            '';
          in [
            { keys = [ 29 57 ]; events = [ "key" ]; command = "DISPLAY=:0 HOME=${me-home} ${feh-bin} -NZ ${workman_keyboard_layout}/workman_keyboard_layout.png &"; }
            { keys = [ 113 ]; events = [ "key" ]; command = "XDG_RUNTIME_DIR=/run/user/105 ${pkgs.alsaUtils}/bin/amixer -q set Master toggle &"; }
            { keys = [ 114 ]; events = [ "key" "rep" ]; command = "XDG_RUNTIME_DIR=/run/user/105 ${pkgs.alsaUtils}/bin/amixer -q set Master 5%- unmute &"; }
            { keys = [ 115 ]; events = [ "key" "rep" ]; command = "XDG_RUNTIME_DIR=/run/user/105 ${pkgs.alsaUtils}/bin/amixer -q set Master 5%+ unmute &"; }
            { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down &"; }
            { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up &"; }
            { keys = [ 224 ]; events = [ "key" "rep" ]; command = "/run/wrappers/bin/light -U 4 &"; }
            { keys = [ 225 ]; events = [ "key" "rep" ]; command = "/run/wrappers/bin/light -A 4 &"; }
            { keys = [ 163 ]; events = [ "key" ]; command = "DISPLAY=:0 ${dbus-mediaplayer2-send} Next &"; }
            { keys = [ 164 ]; events = [ "key" ]; command = "DISPLAY=:0 ${dbus-mediaplayer2-send} PlayPause &"; }
            { keys = [ 165 ]; events = [ "key" ]; command = "DISPLAY=:0 ${dbus-mediaplayer2-send} Previous &"; }
          ];
      };

      # Security
      gnome3.gnome-keyring.enable = true; # gnome's default keyring (TODO: better description)
      # startGnuPGAgent = true;           # alternative to gnome-keyring (TODO: better security, less convenience?)

      # Development
      # hoogle =
      #   {
      #     enable = true;
      #     packages = haskellPackages: with haskellPackages; [ text ]; # TODO: what goes here?
      #   };

      # Editors
      emacs.enable = true;

      # Printing
      printing = {
        enable = true;
      #   # browsing = true;
      #   # defaultShared = true;
      };

      avahi = {
        enable = true;
        nssmdns = true;
        # publish = {
        #   enable = true;
        #   userServices = true;
        # };
      };
    };

    # # Serve binary caches (experimental)
    # # Cant seem to get this working for outside connections:
    # # nix-shell -p nix-serve --run 'nix-serve --listen 192.168.1.203:5000'
    # # nix-shell -p nix-serve --run 'nix-serve --listen 0.0.0.0:5000'
    # # nix-shell -p nix-serve --run 'nix-serve --listen *:5000'
    # services.nix-serve = {
    #   enable = true;
    #   # bindAddress = "192.168.1.0";
    #   # bindAddress = "0.0.0.0";
    #   # bindAddress = "192.168.1.137";
    # };
    # # nix.sshServe = {
    # #   enable = true;
    # #   keys = [];
    # # };
}
