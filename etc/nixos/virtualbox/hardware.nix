{ pkgs
, config
, ...
}:

let
  makePackage = p: p.buildEnv {
    name = "mesa+vbox+txc-${p.mesa_drivers.version}";
    paths =
      let version = "5.1.12";
          virtualboxGuestAdditions = p.linuxPackages.virtualboxGuestAdditions.overrideDerivation (oldAttrs: {
              /* src = p.fetchurl { */
              /*   url = "http://download.virtualbox.org/virtualbox/${version}/VBoxGuestAdditions_${version}.iso"; */
              /*   sha256 = "08a3vycj7yw6ihb3myi9yhag1ivpwdl9m5c33viw66lpmdf2d80k"; */
              /* }; */
              buildCommand = lib.traceShowVal oldAttrs.buildCommand +
                ''
                  ln -s $out/lib/VBoxOGL.so $out/lib/libGL.so
                  ln -s $out/lib/VBoxOGL.so $out/lib/libGL.so.1
                  ln -s $out/lib/VBoxOGL.so $out/lib/libGL.so.1.2.0
                  # TODO: in the next version add EGL? 
                  # patchelf --set-rpath ${lib.makeLibraryPath (with p; with p.xorg; [ "$out" dbus libXcomposite libXdamage libXext libXfixes ])} lib/VBoxEGL.so
                  # cp -v lib/VBoxEGL.so $out/lib
                  # ln -s $out/lib/VBoxEGL.so $out/lib/libEGL.so
                  # ln -s $out/lib/VBoxEGL.so $out/lib/libEGL.so.1
                  # ln -s $out/lib/VBoxEGL.so $out/lib/libEGL.so.1.2.0
                '';
            });
      in
        [ virtualboxGuestAdditions # for the DRI driver
          # p.mesa_drivers
          # p.mesa_drivers.out # mainly for libGL # (TODO: replace?)
          (if config.hardware.opengl.s3tcSupport then p.libtxc_dxtn else p.libtxc_dxtn_s2tc)
        ];
  };
in
{
  hardware = {
    opengl = {
      /* FIXME: See https://github.com/NixOS/nixpkgs/issues/5051#issuecomment-64393958 */
      package = makePackage pkgs;
      /* extraPackages = [pkgs.linuxPackages.virtualboxGuestAdditions]; */
    };
  };
}
