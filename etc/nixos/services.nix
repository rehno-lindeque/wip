{ config
, pkgs
, ... 
}:

{
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";
     
      # Disable capslock (useful for switching caps to a mod key in xmonad/elsewhere)
      # xkbOptions = "ctrl:nocaps";
      # Make capslock into an additional escape key
      xkbOptions = "caps:escape";

      # Gnome desktop
      # * Slightly more familiar than KDE for people who are used to working with Ubuntu
      # * This works well with xmonad
      desktopManager = {
        gnome3.enable = true;
        default = "gnome3";
        # Why this? does it help xmonad? ("the plain xmonad experience")
        xterm.enable = false;
      };

      # Enable XMonad Desktop Environment. (Optional)
      windowManager = {
        xmonad = {
          enable = true; 
          enableContribAndExtras = true;
          # TODO: needed?
          # extraPackages = haskellPackages: [
          #    # haskellPackages.taffybar #todo
          #    haskellPackages.xmonadContrib
          #  ];
        };
        # default = "xmonad";
      };
    
      displayManager = {
        auto = {
          # enable = true;
          # user = "rehno";
        };
      };

      # Screen
      # virtualScreen = { x = 2880 ; y = 1800; };
      # resolutions = { x = 2880 ; y = 1800; };

      # Compose key
      # xkbOptions = "compose:caps";
    };

    # Security
    gnome3.gnome-keyring.enable = true; # gnome's default keyring (TODO: better description)
    # startGnuPGAgent = true;           # alternative to gnome-keyring (TODO: better security, less convenience?)

    # Development 
    # * Instead of running these services this way you might want to take a look
    #   at [nixos-shell](https://github.com/chrisfarms/nixos-shell) instead (although, this seems not maintained anymore)
    # mysql = {
    #   enable = true;
    #   package = pkgs.mysql;
    #   port = 3306;
    #   user = "mysql";
    # };
    # rabbitmq.enable = true;
    # redis.enable = true;
    # dropbox.enable = true;
  };
}
