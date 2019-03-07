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
      (importInputs "${homeProjectsDevelopment}/circuithub/mono/shell.nix" { dev = true; })
      ++ [ 
        # Patched version of linux
        /nix/store/ilkyfznsagirkjvrg89sgf1j96g8pai9-linux-4.19.26-dev
        /nix/store/i17hyy2n5cwn0fgjhl7r4bb51j4h6p00-linux-4.19.26
      ];

  # TODO: basler camera hardware module
  # * https://www.baslerweb.com/en/support/downloads/software-downloads/pylon-5-0-9-linux-x86-64-bit/
  # * https://www.baslerweb.com/fp-1496750153/media/downloads/software/pylon_software/pylon-5.0.9.10389-x86_64.tar.gz
  # * https://github.com/AravisProject/aravis/blob/master/aravis.rules
  services.udev.packages = # if hardware.basler.enable
      let
          basler-camera = pkgs.writeTextFile
                    {
                      # Enable user access to all basler cameras
                      name = "basler-camera";
                      text = ''
                        SUBSYSTEM=="usb", ATTRS{idVendor}=="2676", MODE:="0666", TAG+="uaccess"
                        '';
                      destination = "/etc/udev/rules.d/69-basler-camera.rules";
                    };
      in [ basler-camera ];

  # services.udev.extraRules =
  #   # Permission to use the basler camera usb
  #   # $ lsusb -d 2676:ba02
  #   # Bus 002 Device 024: ID 2676:ba02 Basler AG ace
  #   # (lib.optionalString (!config.hardware.basler.enable)
  #     ''
  #     SUBSYSTEMS=="usb", ATTRS{idVendor}=="2676", ATTRS{idProduct}=="ba02", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  #     # Basler (https://github.com/AravisProject/aravis/blob/master/aravis.rules)
  #     # SUBSYSTEM=="usb", ATTRS{idVendor}=="2676", MODE:="0666", TAG+="uaccess", TAG+="udev-acl"
  #     '';

  # };



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
