{ lib, stdenv, fetchurl, makeWrapper }:
stdenv.mkDerivation rec {
  pname = "striata-reader";
  version = "2.27-3";

  src = fetchurl {
    url = "https://reader.striata.com/downloads/Linux/striata-reader-${version}-amd64.tar.gz";
    sha256 = "12x0b61yv9jlwg7vf72m1cxc2g8d3h94v9gb0ayigibg7n28r1rg";
  };

  # buildInputs = [ makeWrapper ];
  buildPhase = "true";

  libPath = lib.makeLibraryPath []; # (with pkgs; []);

  installPhase = ''
    mkdir -p $out/bin
    cp ./usr/bin/striata-readerc $out/bin/striata-readerc
  '';

  postFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/striata-readerc
  '';
}

