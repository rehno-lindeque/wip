{
  ... 
}:

{
  fonts = {
    fontconfig = { 
      # TODO: see https://wiki.archlinux.org/index.php/Font_configuration#Distorted_fonts
      # 96 is correct for my retina display
      # However, there is no way to set gsettings scaling-factor 2 at the moment for gnome3 without using
      # the gnome3 desktop manager (which is highly redundant with xmonad as the window manager)
      dpi = 144; # 180; # 192; # 96; # 0;
    };
  };
}
