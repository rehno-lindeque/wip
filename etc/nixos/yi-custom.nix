{ pkgs
, haskellPackages ? pkgs.haskell.packages.ghc7101
, ...
}:

let lib = pkgs.haskell.lib; # Haskell nix helpers
in
# note that pkgs.yi refers to the original yi-custom in order to help Yi find the libraries and compiler easily
pkgs.yi.override {
  haskellPackages = haskellPackages; #.override {
  #   overrides = self: super: {
  #     yi-fuzzy-open = lib.dontHaddock (lib.appendConfigureFlag pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts");
  #   };
  # };
  extraPackages = self: with self; [
    yi
    yi-language
    # yi-fuzzy-open
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
