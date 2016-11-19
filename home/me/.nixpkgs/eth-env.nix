{
  # Ethereum foundation
  pkgs
/* , stdenv */
/* , fetchFromGitHub */
/* , fetchurl */
/* , fetchgit */
/* , unzip */
/* , makeWrapper */
/* , makeDesktopItem */
/* , buildEnv */
/* , myEnvFun */

/*   # Ethcore */
/* , rustPlatform */
, ...
}:

let
  inherit (pkgs) stdenv fetchFromGitHub fetchurl fetchgit unzip makeWrapper makeDesktopItem buildEnv myEnvFun rustPlatform;
  /* latestPkgs = pkgs; */
  latestPkgs =
    import
      ( fetchFromGitHub
        {
          owner = "NixOS";
          /* repo = "nixpkgs"; */
          repo = "nixpkgs-channels";
          /* rev = "554ee9558d57b617dc2ba1a7995f8200caf09b11"; */
          /* rev = "aadcffcd75e97394d00f9e4c0d4dfb83cccfe91e"; */
          rev = "4e14fd5d5aac14a17c28465104b7ffacf27d9579";
          sha256 = "0mz62lg25hwvhb85yfhn0vy7biws7j4dq9bg33dbam5kj17f0lca";
        }
      ) {};

  # Ethereum tools
  go-ethereum = with latestPkgs; stdenv.mkDerivation rec {
    name = "go-ethereum-${version}";
    version = "1.4.14";
    rev = "refs/tags/v${version}";
    goPackagePath = "github.com/ethereum/go-ethereum";

    buildInputs = [ go ];

    src = fetchgit {
      inherit rev;
      url = "https://${goPackagePath}";
      /* owner = "ethereum"; */
      /* repo = "go-ethereum"; */
      sha256 = "0bwfpg41lc6c6rn665mqzppjzsb2a6dghzrsn6xbj3j0qkabw9kf";
    };

    buildPhase = ''
      export GOROOT=$(mktemp -d --suffix=-goroot)
      ln -sv ${go}/share/go/* $GOROOT
      ln -svf ${go}/bin $GOROOT
      make all
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp -v build/bin/* $out/bin
    '';

    meta = {
      homepage = "https://ethereum.github.io/go-ethereum/";
      description = "Official golang implementation of the Ethereum protocol";
      license = with stdenv.lib.licenses; [ lgpl3 gpl3 ];
    };
  };

  go-ethereum-classic = with latestPkgs; stdenv.mkDerivation rec {
   inherit (go-ethereum) version buildPhase installPhase;
    name = "go-ethereum-classic-${version}";
    rev = "refs/tags/6aaf5f3";
    goPackagePath = "github.com/ethereumproject/go-ethereum";

    buildInputs = [ go ];

    src = fetchgit {
      url = "https://${goPackagePath}";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };

    meta = {
      homepage = "https://ethereumproject.github.io/go-ethereum/";
      description = "Ethereum classic client";
      license = with stdenv.lib.licenses; [ lgpl3 gpl3 ];
    };
  };

  solidity = with pkgs; stdenv.mkDerivation rec {
    name = "go-ethereum-${version}";
    version = "1.4.11";
    rev = "refs/tags/v${version}";
    goPackagePath = "github.com/ethereum/go-ethereum";

    buildInputs = [ go ];

    src = fetchurl {
      url = "https://github.com/ethereum/solidity/releases/download/${version}/${_name}.zip";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };

    meta = {
      homepage = "TODO"; # TODO
      description = "TODO"; # TODO
      license = with stdenv.lib.licenses; [ lgpl3 gpl3 ]; # TODO
    };
  };

  /* geth = stdenv.mkDerivation rec { */
  /*     name = "geth-${version}"; */
  /*     version = "1.3.5"; */
  /*     buildInputs = */
  /*       with pkgs; */
  /*       [ */
  /*         go */
  /*         gmp */
  /*       ]; */
  /*     src = fetchFromGitHub { */
  /*       owner = "ethereum"; */
  /*       repo = "go-ethereum"; */
  /*       rev = "34b622a24853e1cf550238e8c8be6dfa4178cd35"; */
  /*       sha256 = "00l4558rfjwx0sgswn7m5pj5yq1fng1a8c7lzr0was3419k1bd65"; */
  /*     }; */
  /*     installPhase = '' */
  /*       mkdir -p "$out" */
  /*       cp -r build/bin "$out/bin" */
  /*     ''; */

  /*     meta = with stdenv.lib; { */
  /*       description = "Ethereum blockchain client"; */
  /*       homepage = "https://ethereum.org/"; */
  /*       maintainers = with maintainers; [ dvc ]; */
  /*       license = licenses.gpl3; */
  /*     }; */
  /*   }; */

  mist =
    let
      /* mistPackages = */
      /*   with latestPkgs; [ */
      /*     stdenv.cc.cc glib dbus gnome3.gtk atk pango.out freetype /1* gdk_pixbuf *1/ */
      /*     fontconfig gdk_pixbuf cairo cups expat alsaLib */
      /*     nspr gnome2.GConf nss libnotify libcap go-ethereum systemd */
      /*     /1* nspr gnome3.gconf nss libnotify libcap go-ethereum systemd *1/ */
      /*     xorg.libXrender xorg.libX11 xorg.libXext xorg.libXdamage */
      /*     xorg.libXtst xorg.libXcomposite xorg.libXi xorg.libXfixes */
      /*     xorg.libXrandr xorg.libXcursor xorg.libXScrnSaver */
      /*   ]; */
      mistEnv = buildEnv {
          name = "env-mist";
          paths = with latestPkgs; [
            stdenv.cc.cc glib dbus.lib gnome.gtk atk pango.out freetype /* gdk_pixbuf */
            /* stdenv.cc.cc glib dbus.lib gnome2.gtk atk pango.out freetype /1* gdk_pixbuf *1/ */
            fontconfig.lib gdk_pixbuf cairo cups expat alsaLib
            /* nspr gnome2.GConf nss libnotify libcap go-ethereum systemd */
            nspr gnome.GConf nss libnotify libcap go-ethereum systemd
            /* ???? */
            /* udev udev.all udev.out dbus.all */
            /* nspr gnome3.gconf nss libnotify libcap go-ethereum systemd */
            xorg.libXrender xorg.libX11 xorg.libXext xorg.libXdamage
            xorg.libXtst xorg.libXcomposite xorg.libXi xorg.libXfixes
            xorg.libXrandr xorg.libXcursor xorg.libXScrnSaver
          ];
        };
    in
      stdenv.mkDerivation rec {
        name = "mist-${version}";
        version = "0.8.4";
        /* version = "0.8.1"; */
        platform = "linux64";
        _name = "Ethereum-Wallet-${platform}-${_version}";
        _version = builtins.replaceStrings ["."] ["-"] version;
        src = fetchurl {
          url = "https://github.com/ethereum/mist/releases/download/v${version}/${_name}.zip";
          sha256 = "1aj0lv7x1lv0j2xgyj8i36hbirb2cmi0hgqr57axw72irb2zv289";
          /* sha256 = "0yirpszvk5zgjw1jyiv92947iy1zjx8ki7n6lgj0b3azpg6zf3n9"; */
        };
        icon = fetchurl {
          url = "https://raw.githubusercontent.com/ethereum/mist/master/icons/wallet/icon.png";
          sha256 = "0flyrzy43vxn1gp5qpaiyvhsac588sqgnlpqd13gdr2pay3l5xaz";
        };
        phases = [ "unpackPhase" "installPhase" ];
        buildInputs = [ unzip makeWrapper mistEnv ];
        /* propagatedBuildInputs = mistPackages; */
        /* propagatedBuildInputs = [ latestPkgs.udev ]; */
        installPhase =
          /* with latestPkgs; */
          ''
          unzip "$src"
          mv "$PWD/${_name}" "$out"
          rm "$out/resources/node/geth/geth"
          ln -s "${go-ethereum}/bin/geth" "$out/resources/node/geth/geth"
          chmod +x "$out/Ethereum-Wallet"
          chmod +x "$out/libnode.so"
          patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) "$out/Ethereum-Wallet"
          mkdir "$out/bin"
          ln -s "$out/Ethereum-Wallet" "$out/bin/mist"
          wrapProgram $out/bin/mist \
            --prefix LD_LIBRARY_PATH ":" ${mistEnv}/lib ${mistEnv}/lib64 \
            --prefix LD_LIBRARY_PATH ":" $out/share
          mkdir -p "$out/share/applications"
          cp -r "${desktopItem}/share/applications" "$out/share/"
          # See https://github.com/NixOS/nixpkgs/pull/8819
          # mkdir "$out/lib"
          '';
          # ln -s ${udev}/lib/libudev.so $out/share/applications/libudev.so.0
          # ln -s ${udev}/lib/libudev.so $out/share/applications/libudev.so
        desktopItem = makeDesktopItem {
          name = "mist";
          exec = "mist";
          icon = "${icon}";
          desktopName = "Mist";
          genericName = "Mist Browser";
          comment = meta.description;
          categories = "Categories=Internet;Other;";
        };
        meta = with stdenv.lib; {
          description = "Ethereum wallet";
          homepage = "https://ethereum.org/";
          maintainers = with maintainers; [ dvc ];
          license = licenses.gpl3;
          platforms = platforms.linux;
        };
      };

  # Ethcore node

  /* parity = latestPkgs.rustUnstable.buildRustPackage rec { */
  parity = latestPkgs.rustPlatform.buildRustPackage rec {
    name = "parity-${version}";
    version = "1.3.3";

    src = fetchFromGitHub {
      owner = "ethcore";
      repo = "parity";
      rev = "df4d98001ae5ac9fb162ac9fe7a22c7c3cebc95d";
      sha256 = "13fspacfy4qhpik9737l44mi4x8zjxbkgnqbhfv8xybgwvjd13jk";
    };

    depsSha256 = "0000000000000000000000000000000000000000000000000000";

    meta = with stdenv.lib; {
      description = "Fast, light, robust Ethereum implementation";
      homepage = https://ethcore.io/parity.html;
      license = with licenses; [ gpl3 ];
      maintainers = [];
      platforms = platforms.all;
    };
  };
  
in
  {
    mist = mist;

    # Enter an environment like this:
    #
    #   $ load-env-eth
    #
    ethEnv = myEnvFun
      {
        name = "eth";
        buildInputs =
          [
            /* mist */
            /* go-ethereum */
            /* parity */
          ];
      };

    ethClassicEnv = myEnvFun
      {
        name = "eth-classic";
        buildInputs =
          [
            /* mist */
            /* go-ethereum-classic */
            /* parity-classic */
          ];
      };
  }
