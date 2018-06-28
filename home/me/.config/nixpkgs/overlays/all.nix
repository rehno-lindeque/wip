# let
#   # Unfortunately this causes "GC Warning: Repeated allocation of very large block" warnings
#   # and takes some time to evaluate. For that reason, I'm using unstable as my user channel rather than
#   # cherry-picking from it.
#   unstable = import <nixos-unstable> {};
# in

self: super:

let
  unstable = self;
in

{
  # keybase = super.keybase.overrideDerivation (oldAttrs: rec {
  #   name = "keybase-${version}";
  #   version = "1.0.33";
  #   src = self.fetchFromGitHub {
  #     owner  = "keybase";
  #     repo   = "client";
  #     rev    = "v${version}";
  #     sha256 = "1q6vl07hxz5dbnr8wrv4iwsrza5zshqbxpgp0l1bzc4r51bms4y8";
  #   };
  # });
  # kbfs = super.kbfs.overrideDerivation (oldAttrs: rec {
  #   name = "kbfs-${version}";
  #   version = "20170912.de7c8d8";
  #   src = self.fetchFromGitHub {
  #     owner = "keybase";
  #     repo = "kbfs";
  #     rev = "de7c8d89e1397306050a1bd187385ca050c40823";
  #     sha256 = "1505jdadp57ar0a1b4af87qlr09j147mr07y8v251qrmm847mwci";
  #   };
  # });
  # keybase-gui = super.keybase-gui.overrideDerivation (oldAttrs: rec {
  #   name = "keybase-gui-${version}";
  #   version = "1.0.30-20170714172717.73f9070";
  #   src = self.fetchurl {
  #     # url = "https://s3.amazonaws.com/prerelease.keybase.io/linux_binaries/deb/keybase_${version}_amd64.deb";
  #     url = "https://prerelease.keybase.io/keybase_amd64.deb";
  #     sha256 = "024bdylrvfh86q0qyymxhb6qqhhagaw4w2zmx8b9fvna3p3wg01d";
  #   };
  # });

  # yi = unstable.yi;

  # yi = unstable.yi.overrideAttrs (oldAttrs: { env =
  #   unstable.haskellPackages.ghcWithPackages
  #     (self: [ self.yi ]);
  # });

  # haskellPackages = pkgs.unstable.haskellPackages.override {
  #   overrides = self: super: {
  #     # See https://github.com/NixOS/nixpkgs/issues/28248#issuecomment-332064526
  #     # yi-core            = super.yi-core_0_17_0;
  #     # yi-rope            = super.yi-rope_0_15_0;
  #     # yi-frontend-vty    = super.yi-frontend-vty_0_14_0;
  #     # yi-fuzzy-open      = super.yi-fuzzy-open_0_14_0;
  #     # yi-ireader         = super.yi-ireader_0_14_0;
  #     # yi-keymap-cua      = super.yi-keymap-cua_0_14_0;
  #     # yi-keymap-emacs    = super.yi-keymap-emacs_0_14_0;
  #     # yi-keymap-vim      = super.yi-keymap-vim_0_14_0;
  #     # yi-language        = super.yi-language_0_14_0;
  #     # yi-misc-modes      = super.yi-misc-modes_0_14_0;
  #     # yi-mode-haskell    = super.yi-mode-haskell_0_14_0;
  #     # yi-mode-javascript = super.yi-mode-javascript_0_14_0;
  #     # yi-snippet         = super.yi-snippet_0_14_0;
  #   };
  # };
}
