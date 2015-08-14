

# NixOS configuration-as-tutorial for Haskell developers

# TODO: NOTE THAT THIS IS NOT READY YET (and it might not be for a while)

# About this configuration:
# * This is is a large configuration that gets you set up with NixOS very rapidly while at the same time trying to teach you everything it can about basic Nix configuration.
# * We try to keep things "Haskell"-themed. You might like this config if you use/are interested in any of:
#   * Haskell
#   * XMonad
#   * Emacs
#   * Vim
#   * Yi
#   * ...or if not, perhaps you'll like it for the tutorial + the rest of the config
# * Fork it! Document it! Send a PRs!
#   This is a wiki-style repo, getting commit access is fairly easy: just ask! (but please be considerate)

# How to get started
# * You should not start out with this configuration - use a minimal configuration.nix to install nixos, then swap this one in
# * Once you've swapped 

# Additional notes: 
# * Note that gnome3 tends to install quite a lot of things from the internet
# * After copying this configuration for the first time, run:
#   $ nixos-rebuild switch # activate this configuration
#                          # * the first time I used this command I found I had to
#                          #   repeat it once or twice to complete the install for some reason
#   $ reboot               # you may find that you need to reboot if you've made changes
#                          # to things like the xserver settings

# Help!
# * One quick way to get documentation about an option is http://nixos.org/nixos/options.html
# * Another is nixos-option services.xserver.displayManager
# * Yet another is to search github/gists.
#   e.g. https://github.com/search?l=nix&q=mysql&type=Code
#        https://gist.github.com/search?l=nix&q=mysql

{ config
, pkgs

# * Start by adding the nixos-unstable channel:
#   $ nix-channel --add http://nixos.org/channels/nixos-unstable
#   $ nix-channel --update

# TODO: I no longer do this:
# # * To have <unstable> available as a path in /etc/nixos/configuration.nix do:
# #   $ echo "export NIX_PATH=\$NIX_PATH:unstable=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs" >> /root/.bashrc
# #   and then restart your shell so that
# #   $ echo $NIX_PATH
# #   looks correct
# #   You can also double-check that this worked by running
# #   $ nix-repl
# #   nix-repl> <unstable>
# #             /nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs
# #   nix-repl> (import <unstable> {}).emacs
# #   $ nixos-rebuild
# # * I sometimes set my nixos channel == my unstable channel if the two don't work well together for whatever reason. (e.g. at the moment mysql only works well for me in full unstable)

# TODO: explain how to add <devpkgs>

, ... 
}:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # general configurations
      ./hardware.nix
      ./package-overrides.nix
      ./environment.nix
      ./services.nix
      ./nix.nix
      ./nixpkgs.nix
      ./fonts.nix
      # development
      ./circuithub/services.nix
      # package-specific configurations
      ./vim-configuration.nix
      ./emacs-configuration.nix
      # hacks
      # ./vbox-video-dri.nix
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
      device = "/dev/sda";
    };

    #loader = {
    #  gummiboot.enable = true;
    #  # efi.canTouchEfiVariables = true;
    #};
 
    # Wireless module (turn this on once this is running natively)
    # extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    # initrd.kernelModules = [ "wl" ];
  };

  # Enable networking.
  networking = {
    # hostName = ""; # Define your hostname.
    # hostId = "";
    # # networkmanager.enable = false; 
    # # wireless.enable = true; 
  };

  # List services that you want to enable.
  # User account.
  # * Set a password using
  #   $ useradd -m me ; passwd me
  users.extraUsers.me = {
    group = "users";
    uid = 105;
    createHome = true;
    home = "/home/me";
    # description = "Name Surname";
    # extraGroups = [ "wheel" ]; # essentials
    extraGroups = [ 
      "wheel"          # TODO: allows your user to access stored passwords?
                       # * you need wheel in order to use sudo for example
      "audio"          # ?
      "video"          # ?
      "networkmanager" # ?
      "mysql"          # needed? allows you to use the running mysql service via your user (usefull for software development)
                       # * you will see that the /var/mysql/* files that are created belongs to the mysql user & group
    ];
    isSystemUser = false;
    useDefaultShell = true;
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Configure daemons started automatically by systemd
  systemd = {
    services.mysql.wantedBy = pkgs.lib.mkForce []; # Needed? Force mysql to start?
  };

  # Program settings
  programs = {
    bash.enableCompletion = true; # needed?
    ssh.startAgent = true;        # don't type in a password on every SSH connection that is made
  };

}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
