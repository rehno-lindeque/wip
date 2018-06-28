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

  diwata = self.callPackage (import ./pkgs/diwata.nix) {
    rustPlatform = self.makeRustPlatform rustNightly;
  };

  # https://github.com/seppeljordan/nix-prefetch-github

  daedalus =
    (let
      # daedalusRepo = self.fetchFromGitHub {
      daedalusRepo = self.fetchgit {
              # owner = "input-output-hk";
              # repo = "daedalus";
              url = "https://github.com/input-output-hk/daedalus.git";
              # rev = "0.9.0";
              rev = "a58424a7f6ecd0010a0960b1f5a98ccdc1478a75";
              sha256 = "1m0fcychqacqidz397dqkh2wfhw6j1ifkg9cr196h7i4k6vcsyfr";
              # fetchSubmodules = false;
              leaveDotGit = true;
              # deepClone = true;
            };
    # in (self.callPackage "${daedalusRepo}/installers/nix/linux.nix" { cluster = "mainnet"; })
    in (self.callPackage "${daedalusRepo}/default.nix" {}).daedalus
    # in (self.callPackage "${daedalusRepo}/release.nix" {}).mainnet.installer
    );

  # shorthands
  me-vim = self.vim_configurable.customize {
    vimrcConfig = import ./pkgs/vim/configure.nix { pkgs = self; };
    name = "vim";
  };

  # All patches, services, etc from https://aur.archlinux.org/pkgbase/linux-macbook/?comments=all
  # nix-prefetch remote https://aur.archlinux.org/linux-macbook.git
  arch-linux-macbook = self.stdenv.mkDerivation {
    name = "arch-linux-macbook";
    src = self.fetchgit {
      url = https://aur.archlinux.org/linux-macbook.git;
      rev = "37dd51e7485863783c796448b58732a02b22273e";
      sha256 = "1q7mypgx5800x5jfnjiqbb5w1cjvlxaz8bpx5mbi0mv9bw9qk9r2";
    };
    buildInputs = [];
    phases = [ "unpackPhase" "patchPhase" "buildPhase" ];
    outputs = [ "out" "wakeup" ];
    patchPhase = ''
      substituteInPlace macbook-wakeup.service --replace "xargs" "${self.findutils}/bin/xargs"
      substituteInPlace macbook-wakeup.service --replace "awk" "${self.gawk}/bin/awk"
      substituteInPlace macbook-wakeup.service --replace "echo" "${self.coreutils}/bin/echo"
      '';
    buildPhase = ''
      mkdir -p $out
      cp -r * $out
      mkdir -p $wakeup/lib/systemd/system
      cp macbook-wakeup.service $wakeup/lib/systemd/system/macbook-wakeup.service
    '';
  };

  # neovim = neovim.override
  #   {
  #     vimAlias = true;
  #     configure = import ./pkgs/vim/configure.nix { pkgs = self; };
  #   };

  /* yi-custom = import ./yi-custom.nix { pkgs = self; }; */
  ghc = self.callPackage ./pkgs/ghc.nix {};

  # scripts
  # From https://wiki.archlinux.org/index.php/MacBookPro11,x#Powersave and https://gist.github.com/anonymous/9c9d45c4818e3086ceca
  remove-usb-device = self.writeScript "remove-usb-device"
    ''
    #!/bin/sh
    logger -p info "$0 executed."
    if [ "$#" -eq 2 ];then
      removevendorid=$1
      removeproductid=$2
      usbpath="/sys/bus/usb/devices/"
      devicerootdirs=`ls -1 $usbpath`
      for devicedir in $devicerootdirs; do
        if [ -f "$usbpath$devicedir/product" ]; then
          product=`cat "$usbpath$devicedir/product"`
          productid=`cat "$usbpath$devicedir/idProduct"`
          vendorid=`cat "$usbpath$devicedir/idVendor"`
          if [ "$removevendorid" == "$vendorid" ] && [ "$removeproductid" == "$productid" ];    then
            if [ -f "$usbpath$devicedir/remove" ]; then
              logger -p info "$0 removing $product ($vendorid:$productid)"
              echo 1 > "$usbpath$devicedir/remove"
              exit 0
            else
              logger -p info "$0 already removed $product ($vendorid:$productid)"
              exit 0
            fi
          fi
        fi
      done
    else
      logger -p err "$0 needs 2 args vendorid and productid"
      exit 1
    fi
    '';

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

  ipfs-swarm-key-gen = self.buildGoPackage rec {
    name = "ipfs-swarm-key-gen-${version}";
    rev = "0ee739ec6d322bc1892999882e4738270e97b181";
    version = rev; # 0.0.0
    goPackagePath = "github.com/Kubuxu/go-ipfs-swarm-key-gen";
    # extraSrcPaths = [
    #   (self.fetchgx {
    #     inherit name src;
    #     sha256 = "1khlsahv9vqx3h2smif5wdyb56jrza415hqid7883pqimfi66g3x";
    #   })
    # ];
    src = self.fetchFromGitHub {
      owner = "Kubuxu";
      repo = "go-ipfs-swarm-key-gen";
      inherit rev;
      sha256 = "0zb0b47l76s14xxy41gha1nkw8769975kc8q258r85a36jpgn11j";
    };
    # meta = with self.stdenv.lib; {
    #   description = "This program generates swarm.key file for IPFS Private Network feature.";
    #   homepage = https://ipfs.io/;
    #   license = licenses.mit;
    #   platforms = platforms.unix;
    #   maintainers = with maintainers; [  ];
    # };
  };


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

}
