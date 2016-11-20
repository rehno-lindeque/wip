{
  pkgs
, config
, ... 
}:

{
  boot = {
    # Use the latest kernel for the best hardware support https://github.com/cstrahan/mbp-nixos/blob/master/configuration.nix#L7
    # kernelPackages = pkgs.linuxPackages_4_2; # Disabled because of the amount of recompilation required

    # Extra hardware configuration for macbooks
    extraModprobeConfig = ''
      # TODO: Not sure if noncq is needed for macbook SSD's, but https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix has this
      # TODO: doesn't seem to work...
      # options libata.force=noncq

      # TODO: mpb-nixos has this resume option, but not sure if it's really helpful
      # TODO: doesn't seem to work...
      # options resume=/dev/sda5

      # Sound module for Apple Macs
      options snd_hda_intel index=0 model=intel-mac-auto id=PCH 
      options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
      options snd-hda-intel model=mbp101

      # Pressing 'F8' key will behave like a F8. Pressing 'fn'+'F8' will act as special key 
      options hid_apple fnmode=2
    '';
    initrd =
      {
        availableKernelModules =
          [
            # "xhci_pci"    # ?
            "ehci_pci"      # ?
            # "ahci"        # ?
            "usbhid"        # USB input devices
            "usb_storage"   # USB storage devices
            # "brcmsmac"    # Broadcom wireless device
                            # * Open source brcm80211 kernel driver 
                            # * Appears to be an alternative to b43 (reverse-engineered kernel driver), broadcom-wl (Broadcom driver restricted-license)
                            #   We are using broadcom_sta, see extraModulePackages below
                            # * This is the PCI version of the driver (built-in wireless, not SDIO/USB)
                            # * https://wiki.archlinux.org/index.php/broadcom_wireless#Driver_selection 
                            # * https://github.com/Ericson2314/nixos-configuration/blob/nixos/mac-pro/wireless.nix#L9
            # "i915"          # ? https://github.com/fread2281/dotfiles/blob/master/nixos/laptop.nix#L17
          ];
        kernelModules =
          [
            # "fbcon"    # Make it pretty (support fonts in the terminal)
                         # modprobe: FATAL: Module fbcon not found in directory /nix/store/________________________________-kernel-modules/lib/modules/4.4.2
          ];
      };
    kernelModules =
      [
        "kvm-intel"     # Run kernel-based virtual machines (hypervisor functionality)
        "wl"            # Wireless internet
        "applesmc"      # Sudden motion sensor (enable disk protections etc)
                        # * TODO: needed with an SSD?
      ];
    extraModulePackages =
      [
        config.boot.kernelPackages.broadcom_sta  # Broadcom wireless device
      ];
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
