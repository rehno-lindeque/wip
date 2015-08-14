{ config
, pkgs
, ... 
}:

{
  fonts = {
    # enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      # inconsolata         # monospaced
      ubuntu_font_family  # Ubuntu fonts
      # corefonts
      # liberation_ttf
      # dejavu_fonts
      # terminus_font # for hidpi screens (large font) (see https://gist.github.com/thorhop/9e6b09d2cb0b904ae594 - is this needed for xterm?) 
      # gentium
      # fira
      # lmodern
    ];
    fontconfig = { 
      enable = true;
      ultimate.enable = true;
      dpi = 180; # 192; # 96;
      antialias = true;
      defaultFonts = {
        monospace = [
          "Source Code Pro"
          "Meslo LG S for Lcarsline"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Ubuntu"
          "DejaVu Sans"
        ];
        serif = [
          "PT Serif" "Liberation Serif"
        ];
      };
      hinting = {
        autohint = false;
        enable = true;
        style = "slight";
      };
      includeUserConf = true;
      #includeUserConf = false;
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
  };
}

