{
  applyPatches,
  callPackage,
  piSource,
}: let
  # Reuse upstream's source build with a catalog that includes GPT-6.2.
  nixPackaging = applyPatches {
    name = "pi-nix-packaging";
    src = "${piSource}/nix";
    patches = [./model-catalog.patch];
  };
in
  (callPackage "${nixPackaging}/package.nix" {source = piSource;}).overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      wrapProgram "$out/bin/pi" \
        --set PI_SKIP_VERSION_CHECK 1 \
        --set PI_TELEMETRY 0
    '';
  })
