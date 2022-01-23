{ config, pkgs, lib, ... }:

{
  imports = [
    ../macbookpro115/configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true; # See https://github.com/NixOS/nixos-hardware/pull/68#discussion_r206080663

  # Set the host name for this computer
  networking = {
    hostName = # Define your hostname. #gitignore
  };

  # Mount file systems
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f1e38edd-d1ae-47fe-b7cb-aaaafb0f2b45";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/67E3-17ED";
      fsType = "vfat";
    };

  swapDevices =
    [
      {
        device = "/dev/disk/by-uuid/9c2c7f99-57c7-42a6-bf82-424009b17e18";
      }
    ];

  # Don't kill the machine with too many jobs
  nix.maxJobs = 4;

  # Create the main user
  users.users = {
    me = {
      name = # "me"; #gitignore
      description = # "Name Surname"; #gitignore
    };
  };

  # This is an alternative way of preventing your local builds from being garbage collected
  system.extraDependencies =
    let
      importInputs = path: args:
        let drv = import path args;
        in drv.buildInputs ++ drv.nativeBuildInputs ++ drv.propagatedBuildInputs ++ drv.propagatedNativeBuildInputs;
        # in [ drv ];
      homeProjectsDevelopment = "${config.users.users.me.home}/projects/development";
    in
      # (importInputs "${homeProjectsDevelopment}/circuithub/mono/shell.nix" {}) ++
      [
        # Patched version of linux for rpi (todo: update)
        # /nix/store/ilkyfznsagirkjvrg89sgf1j96g8pai9-linux-4.19.26-dev
        # /nix/store/i17hyy2n5cwn0fgjhl7r4bb51j4h6p00-linux-4.19.26
        # amazon ec2 image for aarch64 ami (todo: update)
        # /nix/store/kf24wjavfjsmckvql17m4mm0534ci9vq-nixos-disk-image
        # nixops aarch64 remote builder (drv doesn't work for this)
        # /nix/store/x59kcx0ylgnjs31hgsckhwpk1rgcc9wb-nixops-machines.drv
        # nixops raspberry pi 3B+ linux image (todo: update)
        # /nix/store/p7nm0nni4kpz7i9sy0p705a4kz1ffz6c-linux-4.19.13
      ];



  # security
  security.apparmor.enable = true;
  services.openssh.enable = false;
  services.fail2ban = {
    enable = true;
    jails = {
      # Prepend to existing ssh-iptables
      ssh-iptables = "enabled  = true";
    };
  };
}
