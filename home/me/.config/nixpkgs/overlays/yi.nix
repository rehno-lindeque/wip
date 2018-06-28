
# let
#   unstable = import <nixpkgs-unstable> {};

#   haskellPackages = unstable.haskell.packages.ghc822.override {
#     overrides = self: super: {
#       # See https://github.com/NixOS/nixpkgs/issues/28248#issuecomment-332064526
#       # gtk2hs-buildtools    = super.gtk2hs-buildtools_0_13_3_0;
#       dynamic-state        = super.dynamic-state_0_3;
#       # text-icu             = unstable.haskell.lib.dontCheck super.text-icu;
#       # cairo                = super.cairo_0_13_4_1;
#       # pango                = super.pango_0_13_4_0;
#       # gtk                  = super.gtk_0_14_7;
#       # yi                   = super.yi.overrideDerivation (drv: {
#       #                          postPatch = super.yi.postPatch + ''
#       #                            echo "HERE... -> $out"
#       #                            pwd
#       #                            ls -r .
#       #                          '';
#       #                        });
#       # yi-core              = super.yi-core_0_17_0;
#       # yi-rope              = super.yi-rope_0_10;
#       # yi-frontend-vty      = super.yi-frontend-vty_0_17_0;
#       # yi-fuzzy-open        = super.yi-fuzzy-open_0_17_0;
#       # yi-ireader           = super.yi-ireader_0_17_0;
#       # yi-keymap-cua        = super.yi-keymap-cua_0_17_0;
#       # yi-keymap-emacs      = super.yi-keymap-emacs_0_17_0;
#       # yi-keymap-vim        = super.yi-keymap-vim_0_16_0;
#       # yi-language          = super.yi-language_0_17_0;
#       # yi-misc-modes        = super.yi-misc-modes_0_17_0;
#       # yi-mode-haskell      = super.yi-mode-haskell_0_17_0;
#       # yi-mode-javascript   = super.yi-mode-javascript_0_17_0;
#       # yi-snippet           = super.yi-snippet_0_17_0;
#     };
#   };
# in

self: super:

{
  # yi =
  #     (super.yi.override {
  #       haskellPackages = haskellPackages;
  #     }).overrideAttrs (oldAttrs: {
  #       # env =
  #       #   haskellPackages.ghcWithPackages
  #       #     (self: [
  #       #       # self.yi
  #       #     ]);
  #     });
}
