
# NixOS configuration-as-tutorial

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

{
  config
, pkgs
, ... 
}:

{
  imports =
    [
      # ./macbookair2013/configuration.nix #gitignore
      # ./virtualbox2015/configuration.nix #gitignore
      # general configurations
      ./boot.nix
      ./hardware.nix
      ./environment.nix
      ./fonts.nix
      ./nix.nix
      ./nixpkgs.nix
      ./package-overrides.nix
      ./programs.nix
      ./services.nix
      ./sound.nix
      ./system.nix
      ./users.nix
      ./virtualisation.nix
      # development
      # ./circuithub/services.nix #gitignore
      # package-specific configurations
      ./vim-configuration.nix
      # ./emacs-configuration.nix # See services.emacs for the new way of doing this
      # hacks
      # ./vbox-video-dri.nix
    ];

  # Configure daemons started automatically by systemd
  systemd = {
    services.mysql.wantedBy = pkgs.lib.mkForce []; # Needed? Force mysql to start?
  };

}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
