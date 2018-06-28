{ stdenv, lib, fetchFromGitHub, cmake, vala, pkgconfig, gtk3, pcre, keybinder3, gettext, imagemagick
, wrapGAppsHook
, enableFFMPEG ? true, ffmpeg ? null
, enableLibAV ? true, libav ? null
, luarocks, luaPackages, moonscript
}:
let
  version = "0.0.0";
in

stdenv.mkDerivation {
  name = "gifine-${version}";

  src = fetchFromGitHub {
    owner = "leafo";
    repo = "gifine";
    rev = "406884680709fa6e3207cee6fd9776ca458c3dbd";
    sha256 = "0dq3dz9rr77jrd42bb1yrz0ib6pxklmayrb1gxvq37rapssdfp2n";
  };

  buildInputs =
    [ # cmake vala gtk3 pcre keybinder3 gettext imagemagick ffmpeg libav
      luaPackages.lgi luarocks moonscript
    ];
  propogatedBuildInputs =
    [ # imagemagick ffmpeg libav
    ];

  nativeBuildInputs =
    [ # pkgconfig wrapGAppsHook
    ];

  meta = with lib; {
    description = "Quickly record and edit gifs and videos of your desktop";
    homepage =  https://github.com/leafo/gifine;
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
