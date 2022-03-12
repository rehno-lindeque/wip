{
  config,
  lib,
  options,
  pkgs,
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

  profiles = {
    allHardware.enable = true;
    installationDevice.enable = true;
    base.enable = true;
    workstation.enable = true;
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

  # # Extra Customization
  # fileSystems."/root" = {
  #   device = "/dev/disk/by-label/home";
  #   fsType = "ext4";
  # };
}
