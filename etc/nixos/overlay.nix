self: super:

let
  rustNightly = super.rust // rec {
    rustc = super.rust.rustc.override {
      configureFlags = [ "--release-channel=nightly" ];
      src = self.fetchurl {
        url = "https://static.rust-lang.org/dist/2018-03-01/rustc-1.24.1-src.tar.gz";
        sha256 = "1vv10x2h9kq7fxh2v01damdq8pvlp5acyh1kzcda9sfjx12kv99y";
      };
      doCheck = false;
    };

    cargo = super.cargo.override {
      inherit rustc;
    };
  };
in
{
  # linux_5_1_rc4 = self.callPackage ./linux-5.1-rc4.nix {};
  # linuxPackages_5_1_rc4 = self.recurseIntoAttrs (self.linuxPackagesFor self.linux_5_1_rc4);

  pdfshuffler = self.callPackage ./pkgs/pdfshuffler {};

  # ledger-live-desktop = self.callPackage ./pkgs/ledger-live-desktop {};

  striata-reader = self.callPackage ./pkgs/striata-reader {};
  striata-reader-env = self.callPackage ./pkgs/striata-reader/env.nix {};

  sss-cli = self.callPackage ./pkgs/sss-cli {
    # rustPlatform = self.makeRustPlatform rustNightly;
  };

  teensyduino = self.callPackage /home/me/projects/development/nixpkgs/pkgs/development/arduino/arduino-core {
    withGui = true;
    withTeensyduino = true;
  };

  mnemonic = self.callPackage ./pkgs/scripts/mnemonic {};

  # See https://github.com/NixOS/nixpkgs/blob/e715283dcaffcd78faed82b483924141a281bdca/pkgs/applications/networking/remote/teamviewer/default.nix
  # See https://github.com/NixOS/nixpkgs/issues/26137
  # teamviewer = self.teamviewer.overrideAttrs (oldAttrs: rec {
  #     name = "teamviewer-${version}";
  #     version = "13.0.6634";
  #     src = pkgs.fetchurl
  #       {
  #         url = "https://dl.tvcdn.de/download/linux/version_13x/teamviewer_${version}_i386.deb";
  #         sha256 = "0v8f2dv5d1f9ymx3v9whmpfrbpnh1k3pcpwv2cvdi9qw7v802dra";
  #         # url = "https://dl.tvcdn.de/download/linux/version_13x/teamviewer_${version}_i386.tar.xz";
  #         # sha256 = "0000000000000000000000000000000000000000000000000000";
  #       };
  #   });

  # norman-keyboard-layout = self.fetchFromGitHub {
  #   owner = "deekayen";
  #   repo = "norman";
  #   rev = "5471ebd0d18eba1b3a5a5f17466a69874765ba0e";
  #   sha256 = "1r317iixr2wy21ncs567vh2i59nydq15fq53nk8b1s3lkivdmiiz";
  # };

  me-keyboard-layout = self.fetchurl {
    url = "https://gist.githubusercontent.com/rehno-lindeque/ad5fef21f15ad13a9a355bbbd41fdc0a/raw/aa7948603ee266bd2a0bb6c9778ae7dd8bd1eccb/xmodmap.norman";
    sha256 = "14a63as7i35g6gkf0sqb324ck9k61w1vsdnz30sf8svnp4c0wjgq";
  };
  # me-keyboard-layout = self.stdenv.mkDerivation rec {
  #   name = "me-keyboard-layout";
  #   src = self.fetchgit {
  #     url = https://gist.github.com/ad5fef21f15ad13a9a355bbbd41fdc0a.git;
  #     rev = "aa7948603ee266bd2a0bb6c9778ae7dd8bd1eccb";
  #     sha256 = "0w0j25ijs0149q9rd6b51kfawza6fm3xzdmw3iar8sac1cfw2ilf";
  #   };
  #   # phases = [ "unpackPhase" "patchPhase" "buildPhase" ];
  #   unpackPhase = "true;";
  #   installPhase = ''
  #     mkdir -p $out
  #     install ${src}/xmodmap.norman $out/xmodmap.norman
  #   '';
  #   #  outputs = [ "out" ];
  #   #  buildInputs = [];
  #   #  phases = [ "unpackPhase" "buildPhase" ];
  #   #  buildPhase = ''
  #   #    mkdir -p $out
  #   #    cp -r * $out
  #   #  '';
  # };

  # xorg = super.xorg // {
  #   luit = super.xorg.luit.override {
  #     outputs = [ "out" "dev" ];
  #   };
  #   luit-2_x = super.xorg.luit.overrideAttrs (oldAttrs: rec {
  #     name = "luit-${version}";
  #     version = "2.0-20180628";
  #     src = self.fetchurl {
  #       url = "ftp://ftp.invisible-island.net/luit/luit-20180628.tgz";
  #       sha256 = "0i28sq051w0igfxirbbn7dwkgfs4ycgf169ypc1rp7jqf8qgd13v";
  #     };
  #   });
  # };

  # blender =
  #   let upstreamBlender = builtins.fetchurl {
  #       url = https://raw.githubusercontent.com/eadwu/nixpkgs/67209e1b20ea7a0ee99c1eb066c9605c7fc71919/pkgs/applications/misc/blender/default.nix;
  #       sha256 = "1h29dcqi7xbb3q7m4qyb0rghmv8bblga7cjgmbfnm2j2cqps9xj1";
  #     };
  #   in self.callPackage upstreamBlender { addOpenGLRunpath = null; };

  # blender = (super.blender.overrideAttrs (oldAttrs: rec {
  #   name = "blender-${version}";
  #   version = "2.8";
  #   # src = self.fetchurl {
  #   #   url = "https://download.blender.org/source/${name}.tar.gz";
  #   #   sha256 = "0000000000000000000000000000000000000000000000000000";
  #   # };
  #   # src = self.fetchgit {
  #   #   url = "git://git.blender.org/blender.git";
  #   #   # rev = "d915e6dc8d9f99756e0b066bda075a8fe8d00dae";
  #   #   rev = "dd3f5186260eddc2c115b560bb832baff0f108ae";
  #   #   sha256 = "0py59mfndrf6lsrdabxnwxm2lxx6x0qcqc0j2c7ajpgri2hh5vc9";
  #   # };
  #   cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DPYTHON_NUMPY_PATH=${self.python36Packages.numpy}/lib/python3.6/site-packages/numpy/core/include" ];
  #   NIX_CFLAGS_COMPILE = oldAttrs.NIX_CFLAGS_COMPILE + " -I${self.python36Packages.numpy}/lib/python3.6/site-packages/numpy/core/include";

  #   buildInputs = oldAttrs.buildInputs ++ [ self.python36Packages.numpy ];
  # })).override { pythonPackages = self.python36Packages; enableNumpy = true; };

  # (let
  #   ml-papers-repo = self.fetchFromGitHub {
  #     src = {
  #     };
  #   }
  #   # ml-papers-repo = self.fetchgit {
  #   #         # owner = "input-output-hk";
  #   #         # repo = "daedalus";
  #   #         url = "https://github.com/input-output-hk/daedalus.git";
  #   #         # rev = "0.9.0";
  #   #         rev = "a58424a7f6ecd0010a0960b1f5a98ccdc1478a75";
  #   #         sha256 = "1m0fcychqacqidz397dqkh2wfhw6j1ifkg9cr196h7i4k6vcsyfr";
  #   #         # fetchSubmodules = false;
  #   #         leaveDotGit = true;
  #   #         # deepClone = true;
  #   #       };
  # # in (self.callPackage "${daedalusRepo}/installers/nix/linux.nix" { cluster = "mainnet"; })
  # in (self.callPackage "${daedalusRepo}/default.nix" {}).daedalus
  # # in (self.callPackage "${daedalusRepo}/release.nix" {}).mainnet.installer
  # );

  # diwata = self.callPackage (import ./pkgs/diwata.nix) {
  #   rustPlatform = self.makeRustPlatform rustNightly;
  # };

  # https://github.com/seppeljordan/nix-prefetch-github

  # daedalus =
  #   (let
  #     # daedalusRepo = self.fetchFromGitHub {
  #     daedalusRepo = self.fetchgit {
  #             # owner = "input-output-hk";
  #             # repo = "daedalus";
  #             url = "https://github.com/input-output-hk/daedalus.git";
  #             # rev = "0.9.0";
  #             rev = "a58424a7f6ecd0010a0960b1f5a98ccdc1478a75";
  #             sha256 = "1m0fcychqacqidz397dqkh2wfhw6j1ifkg9cr196h7i4k6vcsyfr";
  #             # fetchSubmodules = false;
  #             leaveDotGit = true;
  #             # deepClone = true;
  #           };
  #   # in (self.callPackage "${daedalusRepo}/installers/nix/linux.nix" { cluster = "mainnet"; })
  #   in (self.callPackage "${daedalusRepo}/default.nix" {}).daedalus
  #   # in (self.callPackage "${daedalusRepo}/release.nix" {}).mainnet.installer
  #   );

  # shorthands
  me-vim = self.vim_configurable.customize {
    vimrcConfig = import ./pkgs/vim/configure.nix { pkgs = self; };
    name = "vim";
  };

  me-neovim = self.neovim.override {
    # don't alias neovim to vim, yet.
    # vimAlias = true;
    # viAlias = true;
    # withPython = true;
    # withPython3 = true;
    # configure = (import ./customization.nix { pkgs = pkgs; });
    configure = {
      customRC = ''
        # here your custom configuration goes!
      '';
      packages.myVimPackage = with self.vimPlugins; {
        # see examples below how to use custom packages
        start = [ ];
        opt = [ ];
      };
    };
  };

  # # All patches, services, etc from https://aur.archlinux.org/pkgbase/linux-macbook/?comments=all
  # # nix-prefetch remote https://aur.archlinux.org/linux-macbook.git
  # arch-linux-macbook = self.stdenv.mkDerivation {
  #   name = "arch-linux-macbook";
  #   src = self.fetchgit {
  #     url = https://aur.archlinux.org/linux-macbook.git;
  #     rev = "37dd51e7485863783c796448b58732a02b22273e";
  #     sha256 = "1q7mypgx5800x5jfnjiqbb5w1cjvlxaz8bpx5mbi0mv9bw9qk9r2";
  #   };
  #   buildInputs = [];
  #   phases = [ "unpackPhase" "patchPhase" "buildPhase" ];
  #   outputs = [ "out" "wakeup" ];
  #   patchPhase = ''
  #     substituteInPlace macbook-wakeup.service --replace "xargs" "${self.findutils}/bin/xargs"
  #     substituteInPlace macbook-wakeup.service --replace "awk" "${self.gawk}/bin/awk"
  #     substituteInPlace macbook-wakeup.service --replace "echo" "${self.coreutils}/bin/echo"
  #     '';
  #   buildPhase = ''
  #     mkdir -p $out
  #     cp -r * $out
  #     mkdir -p $wakeup/lib/systemd/system
  #     cp macbook-wakeup.service $wakeup/lib/systemd/system/macbook-wakeup.service
  #   '';
  # };

  # neovim = neovim.override
  #   {
  #     vimAlias = true;
  #     configure = import ./pkgs/vim/configure.nix { pkgs = self; };
  #   };

  /* yi-custom = import ./yi-custom.nix { pkgs = self; }; */
  # me-yi = self.callPackage /home/me/.config/yi/shell.nix {}; # "${config.users.users.me.home}/.config/yi/shell.nix" {};

  # ghc = self.callPackage ./pkgs/ghc.nix {};

  # libngspice =
  #   let upstreamLibngspice = builtins.fetchurl {
  #       url = https://raw.githubusercontent.com/NixOS/nixpkgs/7d8d5d4f6f6eab8faf51c3b36738007f45f63991/pkgs/development/libraries/libngspice/default.nix;
  #       sha256 = "07skyzpj6x22alapzrnsgkqipgnfwj2rrj5gplg3l7cpmrdxycn6";
  #     };
  #   in self.callPackage upstreamLibngspice {};

  # kicad =
  #   let
  #     upstreamKicad = builtins.fetchurl {
  #       # https://raw.githubusercontent.com/NixOS/nixpkgs/71b579f9d49e3df0e3e4a6e1478adfc4e52e6aad/pkgs/applications/science/electronics/kicad/default.nix
  #       url = https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/science/electronics/kicad/default.nix;
  #       sha256 = "0nd3nqmw4qmqrpmspa58aisrx29qshwgws363r36r0d6xw1pshmc";
  #     };
  #   in (self.callPackage upstreamKicad {
  #       wxGTK = self.wxGTK30;
  #       boost = self.boost160;
  #     }).overrideAttrs (oldAttrs: {
  #       propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.python ];
  #     });

  # nix-top =
  #   let
  #     upstreamNixTop = builtins.fetchurl {
  #       url = https://raw.githubusercontent.com/NixOS/nixpkgs/8717de96a9d0441c28ce15063adb6f4821cdb3fd/pkgs/tools/package-management/nix-top/default.nix;
  #     };
  #   in self.callPackage upstreamNixTop {};

  # nix-du =
  #   let
  #     upstreamNixDu = builtins.fetchurl {
  #       url = https://raw.githubusercontent.com/NixOS/nixpkgs/8717de96a9d0441c28ce15063adb6f4821cdb3fd/pkgs/tools/package-management/nix-du/default.nix;
  #     };
  #   in self.callPackage upstreamNixDu {};

  # Make actkbd logs more verbose
  actkbd = self.callPackage ./pkgs/actkbd { actkbd = super.actkbd; };

  # nix-prefetch-github = self.writeScriptBin "nix-prefetch-github-sha" ''
  #   nix-prefetch-url --quiet "https://github.com/$1/$2/archive/$3.tar.gz" ''${@:4}
  #   '';

  # nix-diff-drv =
  #   let
  #     src = self.fetchFromGitHub {
  #       owner = "ocharles";
  #       repo = "diff-drv";
  #       rev = "466f9e98dc6af69dddabb0224bf032f74401df2e";
  #       sha256 = "0lg853dgiy0fln9pxjpx6n93h8609v3ck7a1m6xp7c63fwiq5671";
  #     };
  #   in
  #     self.callPackage "${src}/shell.nix" {};

  # ipfs-swarm-key-gen = self.buildGoPackage rec {
  #   name = "ipfs-swarm-key-gen-${version}";
  #   rev = "0ee739ec6d322bc1892999882e4738270e97b181";
  #   version = rev; # 0.0.0
  #   goPackagePath = "github.com/Kubuxu/go-ipfs-swarm-key-gen";
  #   # extraSrcPaths = [
  #   #   (self.fetchgx {
  #   #     inherit name src;
  #   #     sha256 = "1khlsahv9vqx3h2smif5wdyb56jrza415hqid7883pqimfi66g3x";
  #   #   })
  #   # ];
  #   src = self.fetchFromGitHub {
  #     owner = "Kubuxu";
  #     repo = "go-ipfs-swarm-key-gen";
  #     inherit rev;
  #     sha256 = "0zb0b47l76s14xxy41gha1nkw8769975kc8q258r85a36jpgn11j";
  #   };
  #   # meta = with self.stdenv.lib; {
  #   #   description = "This program generates swarm.key file for IPFS Private Network feature.";
  #   #   homepage = https://ipfs.io/;
  #   #   license = licenses.mit;
  #   #   platforms = platforms.unix;
  #   #   maintainers = with maintainers; [  ];
  #   # };
  # };


  # spotify =
  #     pkgs.callPackage
  #       ( pkgs.fetchurl
  #         {
  #           url = https://github.com/thall/nixpkgs/blob/9069aafecc104fc2dc39157b32f59eddaf957a51/pkgs/applications/audio/spotify/default.nix;
  #           sha256 = "1l0ppsps3rz63854i3cfsy4mnkin4pg44fqxx32ykl30ybqzf4y5";
  #         }
  #       )
  #       {};

  # spotify = pkgs.lib.overrideDerivation super.spotify
  #   (let version = "1.0.47.13.gd8e05b1f-47";
  #     in
  #       (attrs: {
  #         name = "spotify-${version}";
  #         src =
  #           fetchurl {
  #             url = "http://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_${version}_amd64.deb";
  #             sha256 = "0079vq2nw07795jyqrjv68sc0vqjy6abjh6jjd5cg3hqlxdf4ckz";
  #           };
  #       })
  #   );

  # # System diagnostics environment
  # diagnostic-env = with self; buildEnv {
  #   name = "diagnostic-env";
  #   paths = with python36Packages; [
  #     lm_sensors    # temperature
  #     usbutils      # list usb devices
  #     powertop      # power/battery management analysis and advice
  #     libsysfs      # list options that are set for a loaded kernel module
  #                   # * https://wiki.archlinux.org/index.php/kernel_modules#Obtaining_information
  #     radeontop     # investigate gpu usage
  #     bmon          # monitor network traffic
  #     pciutils      # list pci devices via lspci
  #     lshw          # list detailed hardware configuration
  #     iw            # wireless scan
  #     wirelesstools # more wireless
  #     rfkill        # more wireless (https://ianweatherhogg.com/tech/2015-08-05-rfkill-connman-enable-wifi.html)
  #                   # To read more about wpa_supplicant see:
  #                   # https://github.com/NixOS/nixpkgs/issues/10804#issuecomment-154971201
  #   ];
  # };

}
