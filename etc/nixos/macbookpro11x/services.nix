{
  pkgs
, config
, lib
, ...
}:

{
  services = {
    xserver = {
      /* videoDrivers = [ "nvidia" ]; */
      /* videoDrivers = [ "xf86-video-nouveau" ]; */

      # use opengl for x11 rendering
      /* useGlamor = true; */
    };


    # Power saving settings
    # * See also http://unix.stackexchange.com/questions/65948/how-do-i-make-powertops-suggestions-permanent
    # * Generated using
    #   nix-shell -p powertop --run 'sudo powertop --csv=/home/me/transient/powertop-report.csv'
    #
    # Powertop suggestions (note that some of these are handled handled elsewhere mostly via tlp):
    #   Enable Audio codec power management;echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
    #   Runtime PM for I2C Adapter i2c-7 (Radeon i2c bit bus 0x97);echo 'auto' > '/sys/bus/i2c/devices/i2c-7/device/power/control';
    #   Autosuspend for USB device Apple Internal Keyboard / Trackpad [Apple Inc.];echo 'auto' > '/sys/bus/usb/devices/1-12/power/control';
    #   Runtime PM for I2C Adapter i2c-6 (Radeon i2c bit bus 0x96);echo 'auto' > '/sys/bus/i2c/devices/i2c-6/device/power/control';
    #   Runtime PM for I2C Adapter i2c-0 (Radeon i2c bit bus 0x90);echo 'auto' > '/sys/bus/i2c/devices/i2c-0/device/power/control';
    #   Autosuspend for USB device Bluetooth USB Host Controller [Broadcom Corp.];echo 'auto' > '/sys/bus/usb/devices/1-8/power/control';
    #   Runtime PM for I2C Adapter i2c-2 (Radeon i2c bit bus 0x92);echo 'auto' > '/sys/bus/i2c/devices/i2c-2/device/power/control';
    #   Runtime PM for I2C Adapter i2c-4 (Radeon i2c bit bus 0x94);echo 'auto' > '/sys/bus/i2c/devices/i2c-4/device/power/control';
    #   Runtime PM for I2C Adapter i2c-1 (Radeon i2c bit bus 0x91);echo 'auto' > '/sys/bus/i2c/devices/i2c-1/device/power/control';
    #   Runtime PM for I2C Adapter i2c-3 (Radeon i2c bit bus 0x93);echo 'auto' > '/sys/bus/i2c/devices/i2c-3/device/power/control';
    #   Runtime PM for I2C Adapter i2c-5 (Radeon i2c bit bus 0x95);echo 'auto' > '/sys/bus/i2c/devices/i2c-5/device/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #1;echo 'auto' > '/sys/bus/pci/devices/0000:00:1c.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation Crystal Well DRAM Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation Crystal Well PCI Express x8 Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:01.1/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family SMBus Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.3/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #4;echo 'auto' > '/sys/bus/pci/devices/0000:00:1c.3/power/control';
    #   Runtime PM for PCI Device Intel Corporation Crystal Well PCI Express x4 Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:01.2/power/control';
    #   Runtime PM for PCI Device Advanced Micro Devices, Inc. [AMD/ATI] Cape Verde/Pitcairn HDMI Audio [Radeon HD 7700/7800 Series];echo 'auto' > '/sys/bus/pci/devices/0000:01:00.1/power/control';
    #   Runtime PM for PCI Device Broadcom Limited 720p FaceTime HD Camera;echo 'auto' > '/sys/bus/pci/devices/0000:05:00.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series Chipset Family Thermal Management Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.6/power/control';
    #   Runtime PM for PCI Device Broadcom Limited BCM43602 802.11ac Wireless LAN SoC;echo 'auto' > '/sys/bus/pci/devices/0000:04:00.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family USB xHCI;echo 'auto' > '/sys/bus/pci/devices/0000:00:14.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family PCI Express Root Port #3;echo 'auto' > '/sys/bus/pci/devices/0000:00:1c.2/power/control';
    #   Runtime PM for PCI Device Intel Corporation HM87 Express LPC Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:1f.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation Crystal Well PCI Express x16 Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:01.0/power/control';
    #   Runtime PM for PCI Device Samsung Electronics Co Ltd Device a801;echo 'auto' > '/sys/bus/pci/devices/0000:02:00.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset Family MEI Controller #1;echo 'auto' > '/sys/bus/pci/devices/0000:00:16.0/power/control';
    #   Runtime PM for PCI Device Advanced Micro Devices, Inc. [AMD/ATI] Venus XT [Radeon HD 8870M / R9 M270X/M370X];echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/power/control';
    #   Runtime PM for PCI Device Intel Corporation 8 Series/C220 Series Chipset High Definition Audio Controller;echo 'auto' > '/sys/bus/pci/devices/0000:00:1b.0/power/control';
    udev.extraRules =
      # * From https://github.com/wkennington/nixos/blob/master/laptop/base.nix#L23
      ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
      '';
        # TODO
        # ACTION=="add", SUBSYSTEM=="module", TEST=="parameters/power_save", ATTR{parameters/power_save}="1"
        # ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
        #
        #     ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol d"
        # OR  ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
        #
        #     ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
        #
        #     ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
        ## this leads to non-responsive input devices
        # ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
  };
}
