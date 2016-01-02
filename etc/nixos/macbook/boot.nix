{
  ... 
}:

{
  boot = {
    # Extra hardware configuration for macbooks
    extraModprobeConfig = ''
      # TODO: Not sure if noncq is needed for macbook SSD's, but https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix has this
      options libata.force=noncq

      # TODO: mpb-nixos has this resume option, but not sure if it's really helpful
      # options resume=/dev/sda5

      # Sound module for Apple Macs
      options snd_hda_intel index=0 model=intel-mac-auto id=PCH 
      options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
      options snd-hda-intel model=mbp101

      # Pressing 'F8' key will behave like a F8. Pressing 'fn'+'F8' will act as special key 
      options hid_apple fnmode=2
    '';
    initrd = {
      # availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" ];
      # availableKernelModules = [ "xhci_pci" "ehci_pci" "usbhid" "usb_storage" ];
      availableKernelModules = [ ];
    };
    # kernelModules = [ "kvm-intel" "wl" ];
    kernelModules = [ ];
    # extraModulePackages = [ "${config.kernelPackages.broadcom_sta}" ];
    extraModulePackages = [ ];
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
