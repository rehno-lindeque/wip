{ haskell
, haskellPackages
, ...
}:

haskellPackages.ghcWithHoogle
  ( self: with self; [
    /* usefull for compiling miscelaneous haskell things */
    cabal-install
    /* zlib */
    /* type-lookup etc for various editors */
    # ghc-mod-dev
    /* ghc-mod */
    /* refactoring tools */
    # HaRe # TODO
    /* search plugins for various editors */
    # hoogle
    # hoogle-index
    # Hayoo
    # hayoo-cli
    /* needed for stylish plugins (vim) */
    /* stylish-haskell */
    /* needed for emacs haskell plugins */
    /* hasktags */
    # vim haskell tags
    # lushtags # needed?
    # haskell-docs
    # present (broken)
    /* needed for vim tagbar */
    /* hscope */
    /* codex */
    /* needed for xmonad */
    /* xmonad */
    /* xmonad-contrib */
    /* xmonad-extras */
  ])

