{pkgs}: let
  version = "0.5.0";
  srcSpec =
    {
      aarch64-linux = {
        url = "https://zmx.sh/a/zmx-${version}-linux-aarch64.tar.gz";
        sha256 = "0p4xzk85ha2b3a110wisrc82kv15yvb0y56r8yhxcvdxhdl9g2ya";
      };
      x86_64-linux = {
        url = "https://zmx.sh/a/zmx-${version}-linux-x86_64.tar.gz";
        sha256 = "0a0clnafaq863vcgb2h42216ygm2g41vv4fbwjxcmkfwajwgdhac";
      };
    }
    .${pkgs.system} or (throw "Unsupported system for zmx: ${pkgs.system}");
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "zmx";
    inherit version;
    src = pkgs.fetchurl srcSpec;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/zmx"
      runHook postInstall
    '';
  }
