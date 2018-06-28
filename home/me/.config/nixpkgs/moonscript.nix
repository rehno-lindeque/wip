{ stdenv, lib, fetchFromGitHub, cmake, vala, pkgconfig, gtk3, pcre, keybinder3, gettext, imagemagick
, wrapGAppsHook
, enableFFMPEG ? true, ffmpeg ? null
, enableLibAV ? true, libav ? null
, luarocks, luaPackages
}:
let
  version = "0.5.0";
  # inherit (luaPackages) buildLuaRocks;
  inherit (luaPackages) buildLuaPackage;
in
  buildLuaPackage {
    name = "moonscript-${version}";

    src = fetchFromGitHub {
      owner = "leafo";
      repo = "moonscript";
      rev = "v${version}";
      sha256 = "0bx6xici852ji5a1zjsrmvr90ynrfykkhwgc5sdj5gvvnhz5k4fd";
    };

    # buildInputs =
    #   [ # cmake vala gtk3 pcre keybinder3 gettext imagemagick ffmpeg libav
    #     # luaPackages.lgi luarocks
    #     luarocks
    #   ];
    # propogatedBuildInputs =
    #   [ # imagemagick ffmpeg libav
    #   ];

    # nativeBuildInputs =
    #   [ # pkgconfig wrapGAppsHook
    #   ];

    meta = with lib; {
      description = "A language that compiles to Lua";
      homepage = http://moonscript.org;
      license = licenses.mit;
      maintainers = with maintainers; [];
      platforms = platforms.linux;
    };
  }
