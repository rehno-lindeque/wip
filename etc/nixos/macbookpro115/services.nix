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
    };
}
