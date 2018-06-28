{ pkgs
, haskellPackages ? pkgs.haskellPackages
, ...
}:

let
  haskellPackages' = haskellPackages.override
    {
      overrides = self: super:
        {
          /* yi = pkgs.haskell.lib.overrideCabal super.yi (drv: { configureFlags = (pkgs.stdenv.lib.remove "-fpango" drv.configureFlags or []) ++ ["-f-pango"]; }); */
          /* yi = pkgs.haskell.lib.addExtraLibraries super.yi [ self.yi-gtk ]; */
          /* yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts"); */
          /* yi = super.yi_0_13_3; */
          # yi = pkgs.haskell.lib.addBuildDepend super.yi [ self.yi-core ];
        };

    };

  yiExtraPackages = self:
    with self;
    [
      /* yi */
      # yi-language
      # yi-fuzzy-open
      # yi-monokai
      # yi-snippet
      # lens
      yi-core
      yi-misc-modes
      yi-mode-haskell
      yi-mode-javascript
    ];

in

{
  yi-custom = # pkgs.yi;
    (pkgs.yi.override {
      haskellPackages = haskellPackages';
      extraPackages = yiExtraPackages;
    });
}
