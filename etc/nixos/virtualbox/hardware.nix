{ pkgs
, config
, ...
}:

let
  makeVideoDrivers = p: p.buildEnv {
    name = "mesa+vbox+txc-${p.mesa_drivers.version}";
    paths =
      [ p.linuxPackages.virtualboxGuestAdditions # for the DRI driver
        # p.mesa_drivers
        p.mesa_drivers.out # mainly for libGL
        (if config.hardware.opengl.s3tcSupport then p.libtxc_dxtn else p.libtxc_dxtn_s2tc)
      ];
  };
in
{
  hardware = {
    opengl = {
      /* FIXME: See https://github.com/NixOS/nixpkgs/issues/5051#issuecomment-64393958 */
      /* package = makeVideoDrivers pkgs; */
      /* package32 = throw "NixOS doesn't support 32-bit dri on 64-bit virtualbox host (yet)."; */
      /* driSupport = true; */
      /* driSupport32Bit = false; */
      extraPackages = [pkgs.linuxPackages.virtualboxGuestAdditions];
    };
  };
  /* services.xserver.videoDrivers = [ "vboxvideo" "ati" "cirrus" "intel" "vesa" "vmware" "modesetting" ]; */
  /* services.xserver.videoDrivers = [ "vboxvideo" ]; */
  services.xserver.videoDrivers = [ "modesetting" ];
}
