{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.nucbox2022;
in {
  options = with lib; {
    profiles.nucbox2022 = {
      enable = mkEnableOption ''
        Whether to enable my nucbox configuration.
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
      playground.enable = true;
    };
    circuithubConfigurations.developerWorkstation.enable = true;

    # Using the systemd-boot EFI boot loader as it seems to be very simple
    boot.loader.systemd-boot.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

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

    networking.hostName = "nucbox2022";

    # Wake up this computer from sleep by sending a magic packet
    # Check that each interface has wake-on-lan using ethtool
    networking.interfaces.enp0s21f0u2u1 = {
      wakeOnLan.enable = true;
      # macAddress = "00:e0:4c:68:0f:e8"; # ip link show enp0s21f0u2u1
    };
    networking.interfaces.wlo2 = {
      # macAddress = "b4:0e:de:a6:78:e5"; # ip link show wlo2
    };
    networking.interfaces.tailscale0 = {
      # wakeOnLan.enable = true; # see https://github.com/tailscale/tailscale/issues/306
    };

    # Turning off powersave for the wifi appears to improve its performance
    # Turn this on when not using a hardwired ethernet connection
    # networking.networkmanager.wifi.powersave = false;

    # Limit the machine to 1 job and 3 out of 4 available cores since it will not primarily be used for building
    # I.e. don't kill the machine while compiling
    nix.settings.max-jobs = 1;
    nix.settings.cores = 3;

    # Add this flake to the local registry so that it's easy
    # to reference on the command line
    nix.registry.wip = {
      from = {
        id = "wip";
        type = "indirect";
      };
      to = {
        path = "${config.users.users.me.home}/projects/wip";
        type = "path";
      };
    };

    sound.mediaKeys.enable = true;

    # Enable ssh so that I can work on the nucbox remotely
    services.openssh = {
      enable = true;
      passwordAuthentication = true; # TODO remove
      # only accessible via the tailscale ip
      listenAddresses = [
        {
          addr = "100.123.235.67";
          port = 22;
        }
      ];
    };
    users.users.me.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDihi25C12vUNxZyxAFVo4lZ4R0bSFmTcNfPQl4mrwNf7116dSMcRilBmkG/x0/G5PRtfz8B+OajtZbK2ivjTwYoDL5+DX50X8jCI4sTjOWBXsw8KcAEu/8NcaIl38tq170YChjUomb3PNqzIvR7fFLAqYxlk01T/42m388WNA2IDTFv1Ex0fkuVOKXnW3ULSZdzLRe7Eh6sSA2qOucue8p+uHgKc9Q9CRhWEkik+iUPO2gTC39LDnMDDtkbeFz6P3R8652kwTSNxV//6FlU0zvvynmxiKjdYUUdWtbkkTZDrH4c5fs6WDem+VfKechS3pvbGQXxcWtYivcgWPDBs9NGyZy0118COhTHF+mgL1jxCu+0Dxfz3/XHS1Efg8rVICI9xjcn2X17ammqWBzsd9navGCXCIJZQQYJSDkU2qUy8anc0834ay88q6wbtcjhXHLmZm/EU+3/B5n54cbTv+zH5EB02dfX/1e7vM1isHvKraKq29HUrY9olmQqf43LjBtE1eoAFXo/tfWDg2aWMvUxXVVYWJ2Q3anyKRlaeN5Mo02uFsusCmRNs7r6lBC0OFbKnkLIG2s0i3BqqVGBV+UctktpmrUZRzhL7o6oiTAhAiKv4ns3B7Yk86JlEW9qkhoysgr4KjsFZD7phg5TDl8ECz+rKT8ZXIRLfXQMOzsOQ== me"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl6tXNgabv6piM5OTpvYV2Y7KEuuw6Pr4FetymvQADC me@desktop2022"
    ];
    systemd.services.sshd = {
      # Make sure sshd starts after tailscale so that it can successfully bind to the ip address
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };

    # Adjust screen brightness at night
    services.redshift.enable = true;

    # Run gnome on this computer for now
    # In future I may switch it to be non-graphical since I normally use it headless
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.lightdm.enable = true;

    # System first installed with release 21.11
    system.stateVersion = "21.11";
  };
}
