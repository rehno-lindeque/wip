{ config
, pkgs
, ... 
}:

{
  fonts = {
    # enableFontDir = true;
    # enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
      # hasklig
      # inconsolata         # monospaced
      # ubuntu_font_family  # Ubuntu fonts
      # corefonts
      # liberation_ttf
      # dejavu_fonts
      # terminus_font # for hidpi screens (large font) (see https://gist.github.com/thorhop/9e6b09d2cb0b904ae594 - is this needed for xterm?) 
      # gentium
      # fira
      # lmodern
    ];
    enableDefaultFonts = true;
    fontconfig = { 
      subpixel = {
        # lcdfilter has no effect at high resolutions (> 200 DPI)
        # lcdfilter = "none";
      };
    };
  };
}

