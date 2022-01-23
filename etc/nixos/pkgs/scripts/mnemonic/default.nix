{ stdenv
, fetchurl
, python2
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "hex-to-mnemonic";
  version = "0.1.0";

  phases = [ "installPhase" ];

  buildInputs = [ makeWrapper python2 ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/hex-to-mnemonic
    chmod +x $out/bin/hex-to-mnemonic
    patchShebangs $out/bin/hex-to-mnemonic
  '';

  src = fetchurl {
    url = https://raw.githubusercontent.com/jrruethe/jrruethe.github.io/63fbc6d50488d17b23d8a7afdbd9350d13e98b42/downloads/code/mnemonic.py;
    sha256 = "0npcpwc55p910xg8pki3f53qws5x42fay0y37zymw6jcif62cfgl";
  };

  meta = with stdenv.lib; {
    description    = "";
    license        = licenses.gpl3;
    maintainers    = with maintainers; [];
    platforms      = platforms.all;
  };
}
