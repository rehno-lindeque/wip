{ pkgs
, haskellPackages ? pkgs.haskellPackages
, ...
}:

let lib = pkgs.haskell.lib; # Haskell nix helpers
    markNotBroken = drv: lib.overrideCabal drv (drv: { broken = false; });
in
# note that pkgs.yi refers to the original yi-custom in order to help Yi find the libraries and compiler easily
pkgs.yi.override {
  haskellPackages = haskellPackages.override {
    /* overrides = self: super: { */
    /*   # yi = markNotBroken super.yi; */
    /*   yi-fuzzy-open = lib.dontHaddock (lib.appendConfigureFlag pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts"); */
    /* }; */
  };
  extraPackages = self: with self; [
    yi
    yi-language
    yi-fuzzy-open
    yi-monokai
    yi-snippet
    lens
  ];
}

# Without yi-custom it would look like this:
# in (ghc.override {
#   overrides = self: super: {
#     yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts");
#   };
# }).ghcWithPackages(self: with self; [
#     yi
#     yi-language
#     yi-fuzzy-open
#     yi-monokai
#     yi-snippet
#     lens
# ])
