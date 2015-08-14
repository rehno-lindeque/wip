# Minimal configuration that gets you started with a gnome3 desktop
# * Note that gnome3 installs a *lot* of stuff from the internet
# * After modifying copying this configuration, run:
#   $ nixos-rebuild switch # sometimes it helps to try again
#                          # if this step fails for some reason
#   $ reboot

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Boot settings.
  boot = {
    initrd = {
      # Disable journaling check on boot because virtualbox doesn't need it
      checkJournalingFS = false; 
      # Make it pretty
      kernelModules = [ "fbcon" ];
    };
    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      version = 2;
      # Define on which hard drive you want to install Grub.
      # device = "/dev/sda";
    };
  };

  # Enable networking.
  networking = {
    # hostName = ""; # Define your hostname.
    # hostId = "";
    # wireless.enable = true;  # not needed with virtualbox
  };

  # List services that you want to enable.
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";

      # Gnome desktop
      # * Slightly more familiar than KDE for people who are used to working with Ubuntu
      # * TODO: Will this works well with xmonad?  
      desktopManager = {
        gnome3.enable = true;
        default = "gnome3";
      };
  
      # Enable XMonad Desktop Environment. (Optional)
      # windowManager = {
      #   xmonad.enable = true; 
      #   xmonad.enableContribAndExtras = true;
      # };
    };
  };
  
  # User account.
  # * Set a password using
  #   $ useradd -m me ; passwd me
  users.extraUsers.me = {
    createHome = true;
    home = "/home/me";
    description = "";
    extraGroups = [ ];
    isSystemUser = false;
    useDefaultShell = true;
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };
  
  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;
 
  # List packages installed in system profile. 
  # * Search for packages by name:
  #   $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    dmenu
    # haskellPackages.ghc
    # haskellPackages.haskellPlatform
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonadContrib
    haskellPackages.xmonadExtras
  ];
}
