# Help!
# * One quick way to get documentation about an option is http://nixos.org/nixos/options.html
# * Another is nixos-option services.xserver.displayManager
# * Yet another is to search github/gists.
#   e.g. https://github.com/search?l=nix&q=mysql&type=Code
#        https://gist.github.com/search?l=nix&q=mysql

{ config
, pkgs
, ...
}:

{
  imports =
    [
      # hardware modules
      ./modules/leds.nix
      ./modules/macbook.nix

      # configuration
      # ./macbookpro2017/configuration.nix #gitignore
      # ./macbookpro115/configuration.nix #gitignore
      # ./macbookair2013/configuration.nix #gitignore
      # ./virtualbox2015/configuration.nix #gitignore

      # general configurations
      ./boot.nix
      ./hardware.nix
      ./environment.nix
      ./fileSystems.nix
      ./fonts.nix
      ./i18n.nix
      ./macbook.nix
      ./networking.nix
      ./nix.nix
      ./nixpkgs.nix
      ./programs.nix
      ./security.nix
      ./services.nix
      ./sound.nix
      ./system.nix
      ./time.nix
      ./users.nix
      ./virtualisation.nix

      # extra customization
      ./modules/actkbd-custom.nix
      # ./modules/ipfs.nix

      # extra services
      # ./modules/diwata
      ./modules/tiny-http-server.nix

      # development
      # ./circuithub/services.nix #gitignore
      # ./circuithub/networking.nix #gitignore
    ];
}
