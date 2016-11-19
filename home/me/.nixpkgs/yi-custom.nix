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
        };

    };

  yiExtraPackages = self:
    with self;
    [
      /* yi */
      yi-language
      yi-fuzzy-open
      yi-monokai
      yi-snippet
      lens
    ];

in

{
  yi-custom = # pkgs.yi;
    (pkgs.yi.override {
      haskellPackages = haskellPackages';
      extraPackages = yiExtraPackages;
    });
}
