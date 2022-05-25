{
  config,
  lib,
  options,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.installer;
in {
  imports = [
    "${flake.inputs.nixpkgs-unstable}/nixos/modules/installer/cd-dvd/iso-image.nix"
  ];

  options = with lib; {
    profiles.installer = {
      enable = mkEnableOption ''
        Whether to enable my installer configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # See https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix
    # (TODO)
    # images.isoImage = {
    isoImage = {
      # enable = true;
      edition = "custom";
      isoName = "installer.iso";
      makeEfiBootable = true;
      makeUsbBootable = true;
    };

    # It's tempting to cram the installer with plenty of software, but this is not necessarily wise.
    # Squashfs takes a very long time to build a large image and much of the pre-loaded software will be replaced by
    # updated software on the installed system in any case.
    profiles = {
      allHardware.enable = true;
      # installationDevice.enable = true; # TODO: this doesn't appear to work
      base.enable = true;
      common.enable = true;
      personalized = {
        enable = true;
        enableSoftware = false;
        enableProblematicSoftware = false;
        enableHome = false;
      };
      preferences.enable = true;
    };

    boot = {
      loader.grub.memtest86.enable = true;

      # Use the latest linux kernel so that the most recent drivers are available
      kernelPackages = pkgs.linuxPackages_latest;

      postBootCommands = ''
        for o in $(</proc/cmdline); do
          case "$o" in
            live.nixos.passwd=*)
              set -- $(IFS==; echo $o)
              echo "nixos:$2" | ${pkgs.shadow}/bin/chpasswd
              ;;
          esac
        done
      '';
    };

    console.packages = options.console.packages.default ++ [pkgs.terminus_font];

    fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;

    fonts.fontconfig.enable = false;

    swapDevices = lib.mkImageMediaOverride [];

    system.stateVersion = lib.mkDefault "21.11";

    # Extra Customization
    # networking.wireless.enable = false; # Use network manager instead

    services.getty.helpLine =
      ''
        NOTES:

            The "nixos" and "root" accounts have empty passwords.
            An ssh daemon is running. You then must set a password
            for either "root" or "nixos" with `passwd` or add an ssh key
            to /home/nixos/.ssh/authorized_keys be able to login.
            If you need a wireless connection, type
            `sudo systemctl start wpa_supplicant` and configure a
            network using `wpa_cli`. See the NixOS manual for details.
      ''
      + lib.optionalString config.services.xserver.enable ''
        Type `sudo systemctl start display-manager' to
        start the graphical user interface.
      ''
      + ''

        INSTALLATION INSTRUCTIONS:

        $ sudo su
        $ install-helper

      '';

    # TODO move to its own package
    # Placing this in system.build enables you to build and inspect the script independently (similar to system.build.nixos-install)
    system.build.install-helper = let
      targetNixosConfiguration = flake.outputs.nixosConfigurations.desktop2022.config.system.build.toplevel.out;
      # targetNixosConfiguration = null;

      # Settings
      # rootDevice = "/dev/sda";
      uefi = true;
      nvme = true;
      # nvme = false;
      rootDevice =
        if nvme
        then "/dev/nvme0n1"
        else "/dev/sda";
      bootSize = 256;
      swapSize = 1024;
      partitionSeparator =
        if nvme
        then "p"
        else "";
      bootPartition = "${rootDevice}${partitionSeparator}1";
      swapPartition = "${rootDevice}${partitionSeparator}2";
      nixosPartition = "${rootDevice}${partitionSeparator}3";
      uefiPartition = "${rootDevice}${partitionSeparator}4";

      # Colors
      nc = "\\e[0m"; # No Color
      white = "\\e[1;37m";

      # Overrides (local paths) for all direct flake inputs, in case there's a problem
      overrideInputArgs =
        lib.concatStringsSep " "
        (lib.mapAttrsToList (k: v: "--override-input ${k} path:${v}") flake.inputs);
    in
      pkgs.writeScriptBin "install-helper" ''
        #!${pkgs.stdenv.shell}
        set -e

        clear -x
        printf "${white}"
        echo "THIS WILL WIPE ALL DATA FROM THIS COMPUTER"
        printf "${nc}"
        echo
        while true; do
            read -p "Do you want to proceed? [yn] " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer with yes or no.";;
            esac
        done
        echo "Continuing..."
        sleep 10

        wipefs -a ${rootDevice}
        dd if=/dev/zero of=${rootDevice} bs=512 count=10000
        sfdisk ${rootDevice} <<EOF
        label: gpt
        device: ${rootDevice}
        unit: sectors
        1 : size=${toString (2048 * bootSize)}, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
        ${lib.optionalString (!uefi) "4 : size=4096, type=21686148-6449-6E6F-744E-656564454649"}
        2 : size=${toString (2048 * swapSize)}, type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F
        3 : type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
        EOF

        mkdir -p /mnt
        mkfs.vfat -n boot ${bootPartition}
        mkswap -L swap ${swapPartition}
        mkfs.ext4 -L nix ${nixosPartition}
        swapon ${swapPartition}

        # Mount the root file system
        mount -t tmpfs none /mnt

        # Required directories
        mkdir -p /mnt/{boot,nix/persistent}

        mount ${bootPartition} /mnt/boot
        mount ${nixosPartition} /mnt/nix

        clear -x
        echo "INSTALL NIXOS"
        printf "${white}"
        # echo '${"\tnixos-install --root /mnt --system $ {targetNixosConfiguration}"}'
        echo '${"\tnixos-install
        \t--root /mnt
        \t--flake github:rehno-lindeque/wip?dir=my-nixos-configurations#desktop2022 # path:${flake}#desktop2022
        \t--override-input circuithub-nixos-configurations ${flake.inputs.circuithub-nixos-configurations}
        \t--override-input nixpkgs-shim/nixpkgs-shim-profiles github:rehno-lindeque/nixpkgs-shim-profiles
        \t# ${overrideInputArgs}"}'
        printf "${nc}"
        echo
        while true; do
            read -p "Do you want to proceed? [yn] " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer with yes or no.";;
            esac
        done
        echo "Continuing..."
        sleep 2

        # nixos-install --root /mnt --system $ {targetNixosConfiguration}
        nixos-install \
          --root /mnt \
          --no-root-passwd \
          --flake github:rehno-lindeque/wip?dir=my-nixos-configurations#desktop2022 \
          --override-input circuithub-nixos-configurations ${flake.inputs.circuithub-nixos-configurations} \
          --override-input nixpkgs-shim/nixpkgs-shim-profiles github:rehno-lindeque/nixpkgs-shim-profiles \
          # ${overrideInputArgs}
      '';

    environment.systemPackages = [config.system.build.install-helper];

    ###########################################################################
    # TEMPORARY
    # TODO: code below comes from installationDevice
    #       there appears to be some import problem with installation device profile

    # Enable in installer, even if the minimal profile disables it.
    documentation.enable = lib.mkForce true;

    # Show the manual.
    documentation.nixos.enable = lib.mkForce true;

    # Default user for installer
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];

      # Initial password is generated with nix run nixpkgs#mkpasswd -- --method=SHA-512
      initialHashedPassword = "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";

      # SSH access so that installation can be completed remotely
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDihi25C12vUNxZyxAFVo4lZ4R0bSFmTcNfPQl4mrwNf7116dSMcRilBmkG/x0/G5PRtfz8B+OajtZbK2ivjTwYoDL5+DX50X8jCI4sTjOWBXsw8KcAEu/8NcaIl38tq170YChjUomb3PNqzIvR7fFLAqYxlk01T/42m388WNA2IDTFv1Ex0fkuVOKXnW3ULSZdzLRe7Eh6sSA2qOucue8p+uHgKc9Q9CRhWEkik+iUPO2gTC39LDnMDDtkbeFz6P3R8652kwTSNxV//6FlU0zvvynmxiKjdYUUdWtbkkTZDrH4c5fs6WDem+VfKechS3pvbGQXxcWtYivcgWPDBs9NGyZy0118COhTHF+mgL1jxCu+0Dxfz3/XHS1Efg8rVICI9xjcn2X17ammqWBzsd9navGCXCIJZQQYJSDkU2qUy8anc0834ay88q6wbtcjhXHLmZm/EU+3/B5n54cbTv+zH5EB02dfX/1e7vM1isHvKraKq29HUrY9olmQqf43LjBtE1eoAFXo/tfWDg2aWMvUxXVVYWJ2Q3anyKRlaeN5Mo02uFsusCmRNs7r6lBC0OFbKnkLIG2s0i3BqqVGBV+UctktpmrUZRzhL7o6oiTAhAiKv4ns3B7Yk86JlEW9qkhoysgr4KjsFZD7phg5TDl8ECz+rKT8ZXIRLfXQMOzsOQ== me"
      ];
    };

    # Allow passwordless sudo from nixos user
    security.sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkForce false;
    };

    # Automatically log in at the virtual consoles.
    services.getty.autologinUser = "nixos";

    # # Some more help text.
    # services.getty.helpLine =
    #   ''
    #     The "nixos" and "root" accounts have empty passwords.
    #     An ssh daemon is running. You then must set a password
    #     for either "root" or "nixos" with `passwd` or add an ssh key
    #     to /home/nixos/.ssh/authorized_keys be able to login.
    #     If you need a wireless connection, type
    #     `sudo systemctl start wpa_supplicant` and configure a
    #     network using `wpa_cli`. See the NixOS manual for details.
    #   ''
    #   + lib.optionalString config.services.xserver.enable ''
    #     Type `sudo systemctl start display-manager' to
    #     start the graphical user interface.
    #   '';

    # Access to the live installer via ssh
    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    # Initial password is generated with nix run nixpkgs#mkpasswd -- --method=SHA-512
    users.users.root.initialHashedPassword = "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";

    networking.hostName = "installer";

    systemd.services.sshd = {
      # Make sure sshd starts after tailscale so that it can successfully bind to the ip address
      after = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };

    # Enable wpa_supplicant, but don't start it by default.
    # networking.wireless.enable = lib.mkDefault true;
    networking.wireless.userControlled.enable = true;
    systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 50 [];

    # # Tell the Nix evaluator to garbage collect more aggressively.
    # # This is desirable in memory-constrained environments that don't
    # # (yet) have swap set up.
    # environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

    # # Make the installer more likely to succeed in low memory
    # # environments.  The kernel's overcommit heustistics bite us
    # # fairly often, preventing processes such as nix-worker or
    # # download-using-manifests.pl from forking even if there is
    # # plenty of free memory.
    # boot.kernel.sysctl."vm.overcommit_memory" = "1";

    # To speed up installation a little bit, include the complete
    # stdenv in the Nix store on the CD.
    system.extraDependencies = with pkgs; [
      stdenv
      stdenvNoCC # for runCommand
      busybox
      jq # for closureInfo
      # For boot.initrd.systemd
      makeInitrdNGTool
      systemdStage1
      systemdStage1Network
    ];

    # Show all debug messages from the kernel but don't log refused packets
    # because we have the firewall enabled. This makes installs from the
    # console less cumbersome if the machine has a public IP.
    networking.firewall.logRefusedConnections = lib.mkDefault false;

    # Prevent installation media from evacuating persistent storage, as their
    # var directory is not persistent and it would thus result in deletion of
    # those entries.
    environment.etc."systemd/pstore.conf".text = ''
      [PStore]
      Unlink=no
    '';

    # Add this flake to the local registry so that it's easy
    # to reference on the command line
    nix.registry = {
      wip = {
        from = {
          id = "my-nixos-configurations";
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
  };
}
