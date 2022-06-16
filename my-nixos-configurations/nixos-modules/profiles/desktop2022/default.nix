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

    # We don't want /tmp to be persisted, but it is on persistent storage due to lack of tmpfs storage space
    boot.cleanTmpDir = true;

    # Don't store docs on this computer since I mostly use it headless for now
    documentation.doc.enable = false;

    # Retain specific system state
    environment.automaticPersistence = {
      normal.path = "/nix/persistent";
    };

    environment.persistence."/nix/persistent" = {
      directories = [
        # Log files
        "/var/log"

        # The /tmp directory requires a large amount of storage space for certain builds, so it can't be on tmpfs
        "/tmp"
      ];

      users.me = {
        directories = [
          # Retain all of my home config for the time being
          ".config"
          # Retain ssh keys for this computer
          {
            directory = ".ssh";
            mode = "0700";
          }
          # Retain my projects directory (for now)
          "projects"
        ];
      };
    };

    fileSystems = {
      # See https://nixos.wiki/wiki/Impermanence
      # Impermanent root file system
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["size=4G" "mode=755"];
      };

      # Impermanent home directory
      "/home/me" = {
        device = "none";
        fsType = "tmpfs";
        options = ["size=4G" "mode=777"];
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
      opengl.extraPackages = with pkgs; [
        mpi
        linuxPackages.nvidia_x11
        cudatoolkit
      ];

      # Sound output doesn't work right now, but we want it to
      pulseaudio.enable = true;

      # Normally provided by not-detected.nix
      enableRedistributableFirmware = true;
    };

    networking.hostName = "desktop2022";

    # Wake up this computer from sleep by sending a magic packet
    # Check that each interface has wake-on-lan using ethtool
    networking.interfaces.eno1 = {
      wakeOnLan.enable = true;
      # macAddress = "d8:5e:d3:83:ca:27"; # ip link show eno1
    };
    networking.interfaces.wlp5s0 = {
      # macAddress = "f8:89:d2:da:bd:49"; # ip link show wlp5s0
    };
    networking.interfaces.tailscale0 = {
      # wakeOnLan.enable = true; # see https://github.com/tailscale/tailscale/issues/306
    };

    # Add this flake to the local registry so that it's easy
    # to reference on the command line
    nix.registry = {
      wip = {
        from = {
          id = "wip";
          type = "indirect";
        };
        to = {
          owner = "rehno-lindeque";
          repo = "wip";
          type = "github";
        };
      };
      my-nixos-configurations = {
        from = {
          id = "my-nixos-configurations";
          type = "indirect";
        };
        to = {
          dir = "my-nixos-configurations";
          owner = "rehno-lindeque";
          repo = "wip";
          type = "github";
        };
      };
    };

    # Make this machine a remote nix builder
    nix.sshServe = {
      enable = true;
      protocol = "ssh-ng";
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDihi25C12vUNxZyxAFVo4lZ4R0bSFmTcNfPQl4mrwNf7116dSMcRilBmkG/x0/G5PRtfz8B+OajtZbK2ivjTwYoDL5+DX50X8jCI4sTjOWBXsw8KcAEu/8NcaIl38tq170YChjUomb3PNqzIvR7fFLAqYxlk01T/42m388WNA2IDTFv1Ex0fkuVOKXnW3ULSZdzLRe7Eh6sSA2qOucue8p+uHgKc9Q9CRhWEkik+iUPO2gTC39LDnMDDtkbeFz6P3R8652kwTSNxV//6FlU0zvvynmxiKjdYUUdWtbkkTZDrH4c5fs6WDem+VfKechS3pvbGQXxcWtYivcgWPDBs9NGyZy0118COhTHF+mgL1jxCu+0Dxfz3/XHS1Efg8rVICI9xjcn2X17ammqWBzsd9navGCXCIJZQQYJSDkU2qUy8anc0834ay88q6wbtcjhXHLmZm/EU+3/B5n54cbTv+zH5EB02dfX/1e7vM1isHvKraKq29HUrY9olmQqf43LjBtE1eoAFXo/tfWDg2aWMvUxXVVYWJ2Q3anyKRlaeN5Mo02uFsusCmRNs7r6lBC0OFbKnkLIG2s0i3BqqVGBV+UctktpmrUZRzhL7o6oiTAhAiKv4ns3B7Yk86JlEW9qkhoysgr4KjsFZD7phg5TDl8ECz+rKT8ZXIRLfXQMOzsOQ== me@macbook2017"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuLt1Tf3H8q6vh96Gw/XnnX60vly5oZqFID0kgGlP1/bYbOxyX3qQDqMVU+tkKr9FST1E6+6pvxVUi2OUz0jyEftLMF9h1n0rY4sLxfDAf9EWliDh4qg5/gP7Whn4DUf9T6Csb+Ctsmfpi1PwpSnE7r43zv8b6sjIHjGXPF5BD1K0PeXihHNkr1ENuCuyEmMdjRGrF4cviodzsiaKBo4L0yRoNx5mNh37dSD5Nqk88GPPn4Y6EUj2E2GjCp8Dc4+DSmG02JGsuRe4D9wlcXeJYzV5lgkIalGNtHpauNxIWEAPSHfYXuy/1IwtPHBvfMtky+59w5t095KuhDBpvzXiwuMlHLUN7EzR28W4yEHVjJxyN8awxtjQagHxO7E7gyTRMPsquUB9r7fpGCA9dsvQbK13lqeghcamOEZH3drKM5C/SlpMOXI8drJu4nvZFLoslUADDWaWh/+8i/NrQwgyUmh8yII1VKFtMGEo8bG+cjDoSR9K6r5sanhoaElyhOIs= me@nucbox2022"
      ];
    };

    # Turn off sandbox because I'm doing machine-learning things with nix that requires sandboxing to be turned off
    # TODO: In future it would be nice to limit this to a specific build user like nix-ssh
    nix.useSandbox = false;

    # Enable ssh so that I can work on the desktop remotely
    services.openssh = {
      enable = true;
      passwordAuthentication = true; # TODO remove
      # only accessible via the tailscale ip
      listenAddresses = [
        {
          addr = "100.89.210.26";
          port = 22;
        }
      ];
    };

    # Initial password is generated with nix run nixpkgs#mkpasswd -- --method=SHA-512
    users.users.me.initialHashedPassword = "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";
    users.users.me.extraGroups = ["networkmanager"];
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

    services.xserver.videoDrivers = ["nvidia"];

    sound.mediaKeys.enable = true;

    # System first installed with release 21.11
    system.stateVersion = "21.11";
  };
}
