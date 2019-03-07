{
  pkgs
, lib
, config
, ...
}:

let

  kernelPackages = config.boot.kernelPackages;

in
{
  services =
    {
      xserver =
        {
          # see https://wiki.archlinux.org/index.php/AMDGPU
          # see https://en.wikipedia.org/wiki/List_of_AMD_graphics_processing_units#Volcanic_Islands_.28Rx_2xx.29_Series
          # nix-shell -p pciutils --run 'lspci | grep -e VGA -e 3D'
          # 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Venus XT [Radeon HD 8870M / R9 M270X/M370X] (rev 83)
          videoDrivers = [ "ati" ];
        };

      udev.extraRules =
        # TODO: investigate whether this duplicates bluetooth.enabled = false;
        # Disabling the bluetooth controller may save battery life.
        # $ lsusb -d 05ac:8290
        # Bus 001 Device 002: ID 05ac:8290 Apple, Inc. Bluetooth Host Controller
        (lib.optionalString (!config.hardware.bluetooth.enable)
          ''
          SUBSYSTEMS=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="8290", RUN+="${pkgs.remove-usb-device} 05ac 8290"
          ''
        ) +
          # TODO: This seems no longer necessary
          # Disable XHC1 acpi to avoid resume directly after suspend
          # See
          # * https://joshtronic.com/2017/03/13/getting-suspend-in-linux-working-on-a-macbook-pro/
          # * https://github.com/simonvandel/dotfiles/blob/f254a4a607257faee295ce798ed215273c342850/nixos/vandel-macair/configuration.nix#L45
          # ''SUBSYSTEM=="pci", KERNEL=="0000:00:14.0", ATTR{power/wakeup}="disabled"'';
          "";
    };
}
