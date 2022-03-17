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
      includeRegular = false;
      includeProblematic = false;
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
  networking.wireless.enable = false; # Use network manager instead

}
