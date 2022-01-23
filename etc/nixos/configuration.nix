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

let
  # Track master branches of personal repos (impure)
  fetchLatest = { path, url }:
    if builtins.pathExists path then
      path
    else
      builtins.fetchGit { inherit url; ref = "master"; };

  myModules = fetchLatest {
    path = "/home/me/projects/config/my-nixos-modules";
    url = "git://github.com/rehno-lindeque/my-nixos-modules.git";
  };
in
{
  imports =
    [
      # Custom modules
      "${myModules}/modules/hardware/basler-camera"
      "${myModules}/modules/hardware/leds"
      "${myModules}/modules/hardware/macbook"
      "${myModules}/modules/hardware/macbook/sdcardreader"
      "${myModules}/modules/hardware/macbook/bluetooth"
      "${myModules}/modules/hardware/teensy"
      "${myModules}/modules/hardware/yubikey"

      # Helpful custom module aliases
      "${myModules}/modules/rename.nix"

      # collections of services
      "${myModules}/modules/services/private-dns.nix"

      # configuration
      # ./macbookpro2017/configuration.nix #gitignore
      # ./macbookair2013/configuration.nix #gitignore

      # general configurations
      ./boot.nix
      ./hardware.nix
      ./environment.nix
      ./fileSystems.nix
      ./fonts.nix
      ./i18n.nix
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


      # WIP
      # /home/me/projects/development/jupyterlab-service/default.nix

      # development
      # ./circuithub/services.nix #gitignore
      # ./circuithub/networking.nix #gitignore
    ];
}
