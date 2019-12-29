{
  config
, pkgs
, lib
, ...
}:

#let
#  writeDeferredBuildScript = package: { automaticallyGC ? false }:
#    let
#      drvPath = builtins.unsafeDiscardOutputDependency package.drvPath;
#      outPath = builtins.unsafeDiscardStringContext package.outPath;
#      drvName = package.name;
#      gcrootDir = "/nix/var/nix/gcroots/deferred-builds";
#    in
#      # Realise the build output. Since this could take hours or even days, it is not done during the course of a
#      # normal nixos rebuild. Note that if a previous output for this service already exists it will end up being
#      # used in the mean time.
#      with pkgs;
#      writeScript "${drvName}-defered-build" (''
#        #!${stdenv.shell}
#        [ -e ${drvPath} ] || { echo 'Unexpectedly missing ${drvPath} is unexpectedly missing.'; exit 1; }
#        # [ -e ${outPath} ] && exit
#        output=$(${nix}/bin/nix-store --realise ${drvPath})
#        ''
#        +
#        # Create a garbage collector root for the newly built output so that it will not be gc'd.
#        # If a gcroot for a previous output exists, it will be replaced so that the old output is now orphaned.
#        #
#        # TODO: possibly use system.activationScripts to clean up these gcroots for services that have been completely
#        #       removed.
#        #
#        ''
#        mkdir -p ${gcrootDir}
#        previous_model=$(readlink ${gcrootDir}/${drvName})
#        ln -sf $output ${gcrootDir}/${drvName}
#        ''
#        +
#        # Automatically garbage collect the previous build output in order to save space.
#        lib.optionalString automaticallyGC ''
#          [ -z $previous ] || nix-store --delete $previous
#          '');

#  # Creates a deferred build service that manages a very expensive build out of band. One example of such a build output
#  # might be a trained machine learning model, which could take hours or days to complete. This allows us to use the
#  # build output in another service, as soon as it is ready rather than waiting on a full system build.
#  #
#  # If automaticallyGC is given, then the previous build output will be automatically garbage collected in order to
#  # save space. Given this flag, the previous build output will only be deleted once the next build output is available.
#  #
#  makeDeferredBuildService = options @ { package, ... }: {
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig = {
#      ExecStart =
#        # Take an exclusive lock in order to build only one model at a time.
#        # Otherwise, it seems likely we would start thrashing due to high memory requirements of training.
#        let
#          scriptOptions = builtins.intersectAttrs { automaticallyGC = true; } options;
#        in
#          "${pkgs.utillinux}/bin/flock /var/lock/deferred-builds.lock -c ${writeDeferredBuildScript package scriptOptions}";
#      Type = "oneshot";
#      # Type = "simple";
#      # Restart = "on-failure";
#      # RestartSec="5min";
#      # Restart = "no";
#    };
#  } // removeAttrs options [ "package" "automaticallyGC" ];

#  unbuildable = pkgs.runCommand "example-unbuildable" {} "echo 'example-unbuildable' > $out";
#  buildable = pkgs.runCommand "example-buildable" {} "echo 'example-buildable' > $out";
#in
{

  # system.extraSystemBuilderCmds = ''
  #   echo "unbuildable drv: ${builtins.unsafeDiscardOutputDependency unbuildable.drvPath}"
  #   echo "buildable drv: ${builtins.unsafeDiscardOutputDependency buildable.drvPath}"
  #   echo "${builtins.unsafeDiscardStringContext unbuildable.outPath}" > $out/extra-lazy-dependencies
  #   echo -n "${builtins.unsafeDiscardStringContext buildable.outPath}" >> $out/extra-lazy-dependencies
  #   '';
  # # system.extraDependencies = [ (builtins.unsafeDiscardStringContext unbuildable.outPath) ];
  # systemd.services.example-1 =
  #   makeDeferredBuildService {
  #     package = pkgs.runCommand "example-1" {} "echo 'Long running build (1)' ; sleep 10 ; echo 'example-1' > $out ; echo 'done (1)' ; exit 1";
  #     automaticallyGC = true;
  #   };

  # systemd.services.example-2 =
  #   makeDeferredBuildService {
  #     package = pkgs.runCommand "example-2" {} "echo 'Long running build (2)' ; sleep 10 ; echo 'example-2' > $out ; echo 'done (2)' ; exit 0";
  #     automaticallyGC = true;
  #   };

  # systemd.services.after-examples = {
  #   after = [ "example-1.service" "example-2.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.coreutils}/bin/echo 'after examples'";
  #     Type = "simple";
  #   };
  # };

  services =
    {
      /* ntpd pauses for a long time during shutdown which is very annoying */
      /* chrony may be the alternative to use (todo) */
      /* ntp.enable = true;         # Keep system clock updated */
      /* services.chrony.enable = true; */
      # timesyncd.enable = true;


      # jupyterlab.enable = true;

      # Interplanetary File System
      ipfs = {
        enable = true;
        emptyRepo = true;
        defaultMode = "offline";
        # autoMount = true; # Not supported in offline mode
        extraFlags = [
          # See https://github.com/ipfs/go-ipfs/issues/3320#issuecomment-511467441
          "--routing=dhtclient"
        ];
        # extraConfig = {
        # };
      };

      # Identity/Key/Cloud storage management
      # keybase.enable = true;
      # kbfs = {
      #   # enable = true;
      #   mountPoint = "/keybase";
      # };

      # Turn on auto-mount
      devmon.enable = true;

      syncthing = {
        # Temporarily disabled
        # enable = true;
        # dataDir = "${config.users.users.me.home}/private-share/syncthing"; (THIS IS NOT THE DATA DIR, it is the config dir)
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
          # wacom.enable = true;
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
        extraGroups = [ "input" "audio" "video" "leds" "messagebus" ];
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
            { keys = [ 113 ]; events = [ "key" ]; command = "XDG_RUNTIME_DIR=/run/user/1005 ${pkgs.alsaUtils}/bin/amixer -q set Master toggle &"; }
            { keys = [ 114 ]; events = [ "key" "rep" ]; command = "XDG_RUNTIME_DIR=/run/user/1005 ${pkgs.alsaUtils}/bin/amixer -q set Master 5%- unmute &"; }
            { keys = [ 115 ]; events = [ "key" "rep" ]; command = "XDG_RUNTIME_DIR=/run/user/1005 ${pkgs.alsaUtils}/bin/amixer -q set Master 5%+ unmute &"; }
            { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down &"; }
            { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up &"; }
            { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -U 4 &"; }
            { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -A 4 &"; }
            # { keys = [ 224 ]; events = [ "key" "rep" ]; command = "/run/wrappers/bin/light -U 4 &"; }
            # { keys = [ 225 ]; events = [ "key" "rep" ]; command = "/run/wrappers/bin/light -A 4 &"; }
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

      # # Editors
      # emacs.enable = true;

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

      # samba = {
      #   enable = true;
      #   nsswins = true;
      # };

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

      privateDns = {
        enable = true;
        useTor = false;
        specificNameServers = {
          #gitignore
          #gitignore
        };
      };
  };
}
