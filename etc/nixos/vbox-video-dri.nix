{ pkgs
, config
, ...
}:

let cfg = config.services.virtualbox;
    kernel = config.boot.kernelPackages;
    makeVideoDrivers = p: p.buildEnv {
      name = "mesa+vbox+txc-${p.mesa_drivers.version}";
      paths =
        [ kernel.virtualboxGuestAdditions # for the DRI driver
          p.mesa_noglu # mainly for libGL
          (if config.hardware.opengl.s3tcSupport then p.libtxc_dxtn else p.libtxc_dxtn_s2tc)
          p.udev
       ];
    };
in
{
  hardware.opengl.package = makeVideoDrivers pkgs;
  hardware.opengl.package32 = throw "NixOS doesn't support 32-bit dri on 64-bit virtualbox host (yet).";
}
