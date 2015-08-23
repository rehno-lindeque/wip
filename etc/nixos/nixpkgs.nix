{ pkgs
, ... 
}:

let devpkgs = import <devpkgs> {}; 
in
{
  nixpkgs.config = {
    # Enable unfree packages
    allowUnfree = true;

    # Browser plugins
    chromium = {
      enableNaCl = false;        # NaCl gives you the ability to run native code safely... not really adopted by anyone yet, so turning it off
      useOpenSSL = false;        # many people have this, maybe they don't trust open ssl?
      enablePepperFlash = true;  # chromium's non-NSAPI alternative to Adobe Flash
      enablePepperPDF = true;    # chromium's non-NSAPI alternative to Adobe PDF
      # enableAdobeFlash = true; # unfree Adobe Flash
      # enableAdobePDF = true;   # unfree Adobe PDF
      enableWideVine = true;     # needed for e.g. Netflix (DRM video)
      hiDPISupport = true;       # if you have a retina screen this is useful to make chrome not look ridiculously small
      cupsSupport = true;        # needed for printing
      pulseSupport = true;       # PulseAudio playback for playing many common audio formats
      proprietaryCodecs = true;  # additional (unfree) nice-to-have codecs (video/audio I think?)
      # gnomeSupport = true;       # ? not sure if this is useful 
    };

    # Overrides
    packageOverrides = pkgs: with pkgs; {
      # package collections
      pluginnames2nix = devpkgs.vimPlugins.pluginnames2nix;           # use the dev version explicitly in order to generate new plugins
      vim-multiple-cursors = devpkgs.vimPlugins.vim-multiple-cursors; # multiple cursors for vim (similar to sublime multiple-cursors)
      vim-nerdtree-tabs = pkgs.vimPlugins.vim-nerdtree-tabs;          #

      # packages in development
      ghc-mod-vim = devpkgs.vimPlugins.ghc-mod-vim;
      mycli = devpkgs.pythonPackages.mycli;
      # sublime = devpkgs.sublime;
      # sublime3 = pkgs.sublime3;
      # ghc-mod-dev = devpkgs.haskellPackages.ghc-mod;
      elmPackages = devpkgs.elmPackages;

      # customizations
      yi-custom = import ./yi-custom.nix { pkgs = devpkgs; };
      # elm-custom = import ./elm-custom.nix { pkgs = pkgs; };
      # chromium-custom = pkgs.chromium.override {
      #   # hiDPISupport = true;   # If you have a retina screen this is useful to make chrome not look ridiculously small
      #   # gnomeSupport = true;   # ?
      # };
    };
  };
}
