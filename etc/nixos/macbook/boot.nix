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
    /* extraModprobeConfig = '' */
    /*   # TODO: Not sure if noncq is needed for macbook SSD's, but https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix has this */
    /*   # TODO: doesn't seem to work... */
    /*   # options libata.force=noncq */

    /*   # TODO: mpb-nixos has this resume option, but not sure if it's really helpful */
    /*   # TODO: doesn't seem to work... */
    /*   # options resume=/dev/sda5 */

    /*   # Sound module for Apple Macs */
    /*   options snd_hda_intel index=0 model=intel-mac-auto id=PCH */ 
    /*   options snd_hda_intel index=1 model=intel-mac-auto id=HDMI */
    /*   options snd-hda-intel model=mbp101 */

    /*   # Pressing 'F8' key will behave like a F8. Pressing 'fn'+'F8' will act as special key */ 
    /*   options hid_apple fnmode=2 */
    /* ''; */
    initrd =
      {
        
        availableKernelModules =
          [
            # "xhci_pci"    # ?
            # "uhci_hcd"    # ?
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
        # TODO: see https://github.com/fooblahblah/nixos/blob/63457072af7b558f63cc5ccec5a75b90a14f35f7/hardware-configuration-mbp.nix
        "kvm-intel"     # Run kernel-based virtual machines (hypervisor functionality, useful for nix containers)
        "applesmc"      # apple system managment controller, regulates fan and other hw goodies
                        # also sudden motion sensor? (enable disk protections etc)
                        # * needed for mbpfan
        "coretemp"      # * recommended by lm-sensors
                        # * needed for mbpfan
        "msr"           # * needed for powersaving, ENERGY_PERF_POLICY_ON_AC, ENERGY_PERF_POLICY_ON_BATTERY in tlp configuration
        "bcm5974"       # Apple trackpad (this doesn't appear to be strictly necessary)
        "hid_apple"     # Apple keyboard (this doesn't appear to be strictly necessary)

        #macbook ___? (TODO)
        # "brcmsmac"      # wireless Needed?
        # "brcmfmac"      # wireless Needed?
      ];

    blacklistedKernelModules =
      [
        # From https://github.com/javins/nixos/blob/master/hardware-configuration.nix#L18:
        # Macbooks don't have PS2 capabilities, and the I8042 driver spams an err like
        # the following on boot:
        #
        # Dec 26 09:43:17 nix kernel: i8042: No controller found
        #
        # This is harmless, but it is noise in the logs when I'm looking for real errors.
        #
        # Alas atkbd was built into nixpkgs here:
        #
        # https://github.com/NixOS/nixpkgs/commit/1c22734cd2e67842090f5d59a6c7b2fb39c1cf66
        #
        # so there isn't a good way to remove it from boot.kernelModules. Thus blacklisting.
        "atkbd"
      ];
  };
}
