{ pkgs
, haskellPackages ? pkgs.haskell.packages.ghc784
, ...
}:

let lib = pkgs.haskell.lib; # Haskell nix helpers
    markNotBroken = drv: lib.overrideCabal drv (drv: { broken = false; });
in (haskellPackages.override {
  overrides = self: super: {
    elm-compiler = lib.dontCheck super.elm-compiler;
    elm-repl = lib.dontCheck super.elm-repl;
    # elm-compiler = markNotBroken (lib.dontCheck super.elm-compiler);
    # elm-make = markNotBroken super.elm-make;
    # elm-repl = markNotBroken (lib.dontCheck super.elm-repl);
    # elm-package = markNotBroken super.elm-package;
  };
}).ghcWithPackages(self: with self; [
    # elm-compiler
    # elm-make
    # elm-package
    # elm-repl
])

