{ stdenv, lib, fetchFromGitHub, cmake, vala, pkgconfig, gtk3, pcre, keybinder3, gettext, imagemagick
, wrapGAppsHook
, enableFFMPEG ? true, ffmpeg ? null
, enableLibAV ? true, libav ? null
}:
let
  version = "1.0.1";
in

stdenv.mkDerivation {
  name = "peek-${version}";

  src = fetchFromGitHub {
    owner = "phw";
    repo = "peek";
    rev = "v${version}";
    sha256 = "1yqvnmgx2x884bi84w1a53ilgv9p34nydwwaql6nfn1p6l7iafqw";
  };

  buildInputs =
    [ cmake vala gtk3 pcre keybinder3 gettext imagemagick ffmpeg libav
    ];
  propogatedBuildInputs =
    [ imagemagick ffmpeg libav
    ];

  nativeBuildInputs = [ pkgconfig wrapGAppsHook ];

  meta = with lib; {
    description = "Simple animated GIF screen recorder with an easy to use interface";
    homepage =  https://github.com/phw/peek;
    license = licenses.gpl3;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
