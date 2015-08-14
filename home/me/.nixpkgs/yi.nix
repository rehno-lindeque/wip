{ pkgs }:

with pkgs;

let ghc = pkgs.haskell.packages.ghc7101;
in
{
  packageOverrides = super: let self = super.pkgs; in
  {
    yi = pkgs.yi.override {
      haskellPackages = ghc.override {
          overrides = self: super: {
            yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts");
          };
        };

      extraPackages = p: with p; [ 
        lens,
        yi,
        yi-language,
        yi-contrib,
        yi-fuzzy-open,
        yi-monokai,
        yi-snippet 
      ];
    };
  };
}

