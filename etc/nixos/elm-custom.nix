{ pkgs
, haskellPackages ? pkgs.haskell.packages.ghc784
, ...
}:

let lib = pkgs.haskell.lib; # Haskell nix helpers
in (haskellPackages.override {
  overrides = self: super: {
    elm-compiler = lib.dontCheck super.elm-compiler;
  };
}).ghcWithPackages(self: with self; [
    elm-compiler
    elm-make
    elm-package
    elm-repl
])

