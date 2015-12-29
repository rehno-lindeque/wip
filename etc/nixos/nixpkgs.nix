{ pkgs
, ...
}:

let devpkgs = import <devpkgs> {};
    unstablepkgs = import <unstablepkgs> {};
    # Use stackage nightly snapshot by default
    haskellPackagesCustom = pkgs.haskellPackages; # pkgs.haskell.packages.lts-3_5;
in
{
  nixpkgs.config = {
    # Enable unfree packages
    allowUnfree = true;

    # Browser plugins
    chromium = {
      # enableNaCl = false;        # NaCl gives you the ability to run native code safely... not really adopted by anyone yet, so turning it off
      # useOpenSSL = false;        # many people have this, maybe they don't trust open ssl?
      enablePepperFlash = true;  # chromium's non-NSAPI alternative to Adobe Flash
      enablePepperPDF = true;    # chromium's non-NSAPI alternative to Adobe PDF
      # enableAdobeFlash = true; # unfree Adobe Flash
      # enableAdobePDF = true;   # unfree Adobe PDF
      # enableWideVine = true;     # needed for e.g. Netflix (DRM video)
      hiDPISupport = true;       # if you have a retina screen this is useful to make chrome not look ridiculously small
      # cupsSupport = true;        # needed for printing
      pulseSupport = true;       # PulseAudio playback for playing many common audio formats
      proprietaryCodecs = true;  # additional (unfree) nice-to-have codecs (video/audio I think?)
      # gnomeSupport = true;       # ? not sure if this is useful 
    };

    # Overrides
    packageOverrides = pkgs: with pkgs; {
      # shorthands
      pluginnames2nix = devpkgs.vimPlugins.pluginnames2nix;             # use the dev version explicitly in order to generate new plugins
      vim-multiple-cursors = pkgs.vimPlugins.vim-multiple-cursors; # multiple cursors for vim (similar to sublime multiple-cursors)
      vim-nerdtree-tabs = pkgs.vimPlugins.vim-nerdtree-tabs;          #
      ghc-mod-vim = pkgs.vimPlugins.ghc-mod-vim;
      mycli = pkgs.pythonPackages.mycli;

      # customizations
      haskelPackages-custom = haskellPackagesCustom;
      yi-custom = import ./yi-custom.nix { pkgs = pkgs; haskellPackages = haskellPackagesCustom; };
      ghc-custom = import ./ghc-custom.nix { pkgs = pkgs; haskellPackages = haskellPackagesCustom; };
      # elm-custom = import ./elm-custom.nix { pkgs = pkgs; };
      # chromium-custom = pkgs.chromium.override {
      #   # hiDPISupport = true;   # If you have a retina screen this is useful to make chrome not look ridiculously small
      #   # gnomeSupport = true;   # ?
      # };

      # packages in development
      # sublime = devpkgs.sublime;
      # sublime3 = devpkgs.sublime3;
      # ghc-mod-dev = pkgs.haskellPackages.ghc-mod;
      # elmPackages = devpkgs.elmPackages;
      vim-jade = unstablepkgs.vimPlugins.vim-jade;
      heroku = devpkgs.heroku;

      # packages in unstable
      elmPackages = devpkgs.elmPackages;

    };
  };
}
