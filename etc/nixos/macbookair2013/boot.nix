{
  ... 
}:

{
  boot = {
    loader = {
      grub = {
        # From nixos-in-place.nix
        device = "/dev/sda";
        storePath = "/nixos/nix/store";
      };
    };
    initrd = {
      # From nixos-in-place.nix
      supportedFilesystems = [ "ext4" ];
      postDeviceCommands = ''
        mkdir -p /mnt-root/old-root ;
        mount -t ext4 /dev/sda6 /mnt-root/old-root ;
      '';
    };

    # TODO: is this still needed? macbookpro115 simply includes <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
    extraModulePackages =
      [
        config.boot.kernelPackages.broadcom_sta  # Broadcom wireless device
      ];
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
