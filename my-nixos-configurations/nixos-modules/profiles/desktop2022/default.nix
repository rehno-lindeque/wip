{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop2022;
in {
  options = with lib; {
    profiles.desktop2022 = {
      enable = mkEnableOption ''
        Whether to enable my desktop configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    profiles = {
      common.enable = true;
      workstation.enable = true;
      personalized = {
        enable = true;
        enableSoftware = true;
        enableProblematicSoftware = false;
        enableHome = true;
      };
      preferences.enable = true;
      # playground.enable = true;
    };

    # Using the systemd-boot EFI boot loader as it seems to be very simple
    boot.loader.systemd-boot.enable = true;

    boot.initrd.availableKernelModules = [
      # nvme is required in order to mount the root file system during boot
      "nvme"
    ];

    # Kernel >= 5.17 is required for the wifi driver (MT7921K (RZ608))
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_17;

    fileSystems = {
      # See https://nixos.wiki/wiki/Impermanence
      # Impermanent root file system
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "size=3G" "mode=755" ];
      };

      # Impermanent home directory
      "/home/me" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "size=4G" "mode=777" ];
      };

      # Files managed by nix, including the nix store
      "/nix" = {
        device = "/dev/disk/by-label/nix";
        fsType = "ext4";
        neededForBoot = true;
      };

      # Boot partition
      "/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };
    };

    swapDevices = [
      {device = "/dev/disk/by-label/swap";}
    ];

    hardware = {
      opengl.enable = true;

      # Sound output doesn't work right now, but we want it to
      pulseaudio.enable = true;

      # Normally provided by not-detected.nix
      enableRedistributableFirmware = true;
    };

    networking.hostName = "desktop2022";

    # # Limit cpu use to 14 out of the 16 available
    # nix.buildCores = 14;

    # # Add this flake to the local registry so that it's easy
    # # to reference on the command line
    # nix.registry.wip = {
    #   from = {
    #     id = "wip";
    #     type = "indirect";
    #   };
    #   to = {
    #     path = "${config.users.users.me.home}/projects/wip";
    #     type = "path";
    #   };
    # };

    sound.mediaKeys.enable = true;

    # Enable ssh so that I can work on the desktop remotely
    services.openssh = {
      enable = true;
      passwordAuthentication = true; # TODO remove
      # only accessible via the tailscale ip
      listenAddresses = [
        {
          addr = "100.101.249.69";
          port = 22;
        }
      ];
    };
    users.mutableUsers = false;

    # Initial password is generated with nix run nixpkgs#mkpasswd -- --method=SHA-512
    users.users.me.initialHashedPassword = "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";
    users.users.root.initialHashedPassword = "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";

    users.users.me.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDihi25C12vUNxZyxAFVo4lZ4R0bSFmTcNfPQl4mrwNf7116dSMcRilBmkG/x0/G5PRtfz8B+OajtZbK2ivjTwYoDL5+DX50X8jCI4sTjOWBXsw8KcAEu/8NcaIl38tq170YChjUomb3PNqzIvR7fFLAqYxlk01T/42m388WNA2IDTFv1Ex0fkuVOKXnW3ULSZdzLRe7Eh6sSA2qOucue8p+uHgKc9Q9CRhWEkik+iUPO2gTC39LDnMDDtkbeFz6P3R8652kwTSNxV//6FlU0zvvynmxiKjdYUUdWtbkkTZDrH4c5fs6WDem+VfKechS3pvbGQXxcWtYivcgWPDBs9NGyZy0118COhTHF+mgL1jxCu+0Dxfz3/XHS1Efg8rVICI9xjcn2X17ammqWBzsd9navGCXCIJZQQYJSDkU2qUy8anc0834ay88q6wbtcjhXHLmZm/EU+3/B5n54cbTv+zH5EB02dfX/1e7vM1isHvKraKq29HUrY9olmQqf43LjBtE1eoAFXo/tfWDg2aWMvUxXVVYWJ2Q3anyKRlaeN5Mo02uFsusCmRNs7r6lBC0OFbKnkLIG2s0i3BqqVGBV+UctktpmrUZRzhL7o6oiTAhAiKv4ns3B7Yk86JlEW9qkhoysgr4KjsFZD7phg5TDl8ECz+rKT8ZXIRLfXQMOzsOQ== me"
    ];
    systemd.services.sshd = {
      # Make sure sshd starts after tailscale so that it can successfully bind to the ip address
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };

    # Adjust screen brightness at night
    services.redshift.enable = true;

    # Run gnome on this computer
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.lightdm.enable = true;

    # Retain specific system state
    environment.automaticPersistence = {
      normal.path = "/nix/persistent";
    };
    environment.persistence."/nix/persistent" = {
      directories = [
        # Log files
        "/var/log"
      ];
      files = [
        # Ssh id for nix remote builder
        "/etc/nix/id_rsa"
      ];
    };
  };
}