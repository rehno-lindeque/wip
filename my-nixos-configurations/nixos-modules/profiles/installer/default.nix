{
  config,
  lib,
  options,
  pkgs,
  flake,
  ...
}: {
  # See https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix
  isoImage = {
    enable = true;
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
    installationDevice.enable = true;
    base.enable = true;
    workstation.enable = true;
    personalized = {
      enable = true;
      full = false;
    };
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
  # (Loosely based on on steps listed in https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix)

  # TODO:
  # When kernel modules are locked, the ext4 module cannot be loaded in order to mount the newly created filesystem
  # security.lockKernelModules = false;

  # TODO
  # boot.loader.efi.canTouchEfiVariables = true; # This only needs to be turned on initially for nixos-install

  networking.wireless.enable = false; # Use network manager instead

  services.getty.helpLine = ''
    INSTRUCTIONS:

    $ sudo su
    $ install-helper

  '';

  # TODO move to its own package
  # Placing this in system.build enables you to build and inspect the script independently (similar to system.build.nixos-install)
  # nix build .#nixosConfigurations.installer.config.system.build.install-nukbox
  system.build.install-helper = let
    targetNixosConfiguration = flake.outputs.nixosConfigurations.nukbox.config.system.build.toplevel.out;
    # targetNixosConfiguration = null;

    # Settings
    # rootDevice = "/dev/nvme0n1";
    rootDevice = "/dev/sda";
    uefi = true;
    # nvme = true;
    nvme = false;
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
      mkfs.ext4 -L nixos ${nixosPartition}
      swapon ${swapPartition}
      mount ${nixosPartition} /mnt
      mkdir /mnt/boot
      mount ${bootPartition} /mnt/boot

      clear -x
      echo "INSTALL NIXOS"
      printf "${white}"
      echo '${"\tnixos-install --root /mnt --system ${targetNixosConfiguration}"}'
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

      nixos-install --root /mnt --system ${targetNixosConfiguration}
    '';

  environment.systemPackages = [config.system.build.install-helper];
}
