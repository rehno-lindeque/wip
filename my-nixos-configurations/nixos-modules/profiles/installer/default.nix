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
    networking.wireless.enable = false; # Use network manager instead

    ###########################################################################
    # TEMPORARY
    # TODO: code below comes from installationDevice
    #       there appears to be some import problem with installation device profile

    # Enable in installer, even if the minimal profile disables it.
    documentation.enable = lib.mkForce true;

    # Show the manual.
    documentation.nixos.enable = lib.mkForce true;

    # Use less privileged nixos user
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      # Allow the graphical user to login without password
      initialHashedPassword = "";
    };

    # Allow the user to log in as root without a password.
    users.users.root.initialHashedPassword = "";

    # Allow passwordless sudo from nixos user
    security.sudo = {
      enable = true;
      wheelNeedsPassword = lib.mkForce false;
    };

    # Automatically log in at the virtual consoles.
    services.getty.autologinUser = "nixos";

    # Some more help text.
    services.getty.helpLine =
      ''
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
      '';

    # We run sshd by default. Login via root is only possible after adding a
    # password via "passwd" or by adding a ssh key to /home/nixos/.ssh/authorized_keys.
    # The latter one is particular useful if keys are manually added to
    # installation device for head-less systems i.e. arm boards by manually
    # mounting the storage in a different system.
    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
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
  };
}
