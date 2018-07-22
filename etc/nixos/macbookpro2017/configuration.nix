{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../macbookpro115/configuration.nix
    ];

  # Set the host name for this computer
  networking = {
    hostName = # Define your hostname. #gitignore
  };

  # This is an alternative way of preventing your local builds from being garbage collected
  system.extraDependencies = [
    #gitignore
  ];

}
