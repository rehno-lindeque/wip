{ pkgs
, ...
}:

{
  nixpkgs = {
    config = {
      chromium = {
        enablePepperFlash = true;
        enablePepperPDF = true;
        enableWideVine = true;     # needed for e.g. Netflix (DRM video)
      };
      packageOverrides = pkgs: {
        # Bluetooth stuff
        # bluez = pkgs.bluez5;
        # Enable thunderbolt
        # * https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix#L194
        # Full support for Broadcom wireless modem (not sure if this is necessary?)
        # * https://github.com/cstrahan/mbp-nixos/blob/40c24909df8a6e19b7d3ff085de1c676ac54f879/configuration.nix#L68
        # * https://wireless.wiki.kernel.org/en/users/drivers/brcm80211 
        # Disabled for now due to the amount of recompilation required
        # linux_4_2 = pkgs.linux_4_2.override {
        #   extraConfig = ''
        #     BRCMFMAC_PCIE y
        #   '';
        #   # THUNDERBOLT m
        # };

      };
    };
  };
}
