{
  pkgs,
  zmx,
}:
zmx.packages.${pkgs.system}.default.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    cp ${./build.zig.zon2json-lock} build.zig.zon2json-lock
  '';
})
