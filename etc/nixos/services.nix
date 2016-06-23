{
  config
, pkgs
, lib
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

      # Key bindings
      # * Disable capslock (useful for switching caps to a mod key in xmonad/elsewhere)
      # xkbOptions = "ctrl:nocaps";
      # * Terminate current session using ctrl + alt + backspace (usefull on macs)
      # * Make capslock into an additional escape key
      xkbOptions = "terminate:ctrl_alt_bksp, caps:escape";


      # Enable XMonad Desktop Environment. (Optional)
      windowManager = {
        default = "xmonad";
        xmonad = {
          enable = true; 
          enableContribAndExtras = true;
          # TODO: needed?
          # extraPackages = haskellPackages: [
          #    # haskellPackages.taffybar #todo
          #    haskellPackages.xmonadContrib
          #  ];
        };
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

  };
}
