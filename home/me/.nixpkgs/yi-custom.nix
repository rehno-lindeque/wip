{ pkgs
, haskellPackages ? pkgs.haskellPackages #  pkgs.haskell.packages.ghc7103
, ...
}:

let
  haskellPackages' = haskellPackages.override
    {
      overrides = self: super:
        {
          yi =
            /* pkgs.haskell.lib.addExtraLibraries super.yi [ self.yi-gtk ]; */
            pkgs.haskell.lib.overrideCabal super.yi
              (drv:
                {
                  configureFlags = (pkgs.stdenv.lib.remove "-fpango" drv.configureFlags or []) ++ ["-f-pango"];
                }
              );

            /* pkgs.haskell.lib.addExtraLibraries super.yi [ self.glib self.gtk ]; */
          /* yi = */
          /*   pkgs.haskell.lib.addExtraLibrary self.glib super.yi; */
          /*   pkgs.haskell.lib.addBuildDepend self.glib super.yi; */
          /* yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts"); */
        };

    };

  yiExtraPackages = self:
    with self;
    [
      yi
      yi-language
      /* yi-fuzzy-open */
      /* yi-monokai */
      /* yi-snippet */
      lens
    ];

in

{
  yi-custom =
    (pkgs.yi.override {
      haskellPackages = haskellPackages';
      extraPackages = yiExtraPackages;
    }).overrideDerivation (self: {
      /* propagatedBuildInputs = [ pkgs.glib ]; */
      /* propagatedBuildInputs = with pkgs; [which pkgconfig file glib gtk2 gtk3 curl]; */
      libraryPkgconfigDepends = [ pkgs.gtk2 ];
    });
    /* pkgs.buildEnv */
    /*   { */
    /*     name = "yi-custom"; */
    /*     paths = [ ( haskellPackages'.ghcWithPackages yiExtraPackages) ]; */
    /*   }; */
}

/* let # Helpers from haskell-modules/lib.nix */
/*     lib = pkgs.haskell.lib; */
/*     ghc = pkgs.haskell.packages.ghc7101; */
/* in */
/* # note that pkgs.yi refers to the original yi-custom in order to help Yi find the libraries and compiler easily */
/* pkgs.yi.override { */
/*   haskellPackages = ghc.override { */
/*     overrides = self: super: { */
/*       yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts"); */
/*     }; */
/*   }; */
/*   extraPackages = self: with self; [ */
/*     yi */
/*     yi-language */
/*     yi-fuzzy-open */
/*     yi-monokai */
/*     yi-snippet */
/*     lens */
/*   ]; */
/* } */

/* # Without yi-custom it would look like this: */
/* # in (ghc.override { */
/* #   overrides = self: super: { */
/* #     yi-fuzzy-open = lib.appendConfigureFlag (lib.dontHaddock pkgs.haskellPackages.yi-fuzzy-open "--ghc-option=-XFlexibleContexts"); */
/* #   }; */
/* # }).ghcWithPackages(self: with self; [ */
/* #     yi */
/* #     yi-language */
/* #     yi-fuzzy-open */
/* #     yi-monokai */
/* #     yi-snippet */
/* #     lens */
/* # ]) */
