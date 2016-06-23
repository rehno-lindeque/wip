{ pkgs
, ...
}:

let devpkgs = import <devpkgs> {};
    unstablepkgs = import <unstablepkgs> {};
in
{
  nixpkgs = {
    config = {
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
        # proprietaryCodecs = true;  # additional (unfree) nice-to-have codecs (video/audio I think?)
        # gnomeSupport = true;       # ? not sure if this is useful 
      };

      # Overrides
      packageOverrides = pkgs: with pkgs; {
        # Use the development version of pluginname2nix explicitly (in order to generate new vim packages)
        pluginnames2nix = devpkgs.vimPlugins.pluginnames2nix;

        # packages in development
        # ghc-mod-dev = pkgs.haskellPackages.ghc-mod;
        # elmPackages = devpkgs.elmPackages;
        vim-jade = unstablepkgs.vimPlugins.vim-jade;
        heroku-beta = devpkgs.heroku;

        # packages in unstable
        elmPackages = devpkgs.elmPackages;
      };
    };
  };
}
