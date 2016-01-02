{
  pkgs
, ...
}:

{
  services = {
    locate.enable = true;
    mpd.enable = true;
    upower.enable = true;

    xserver = {
      xkbVariant = "mac";
      videoDrivers = [ "intel" "nouveau" ];
      vaapiDrivers = [ pkgs.vaapiIntel ];

      multitouch = {
        enable = true;
        # invertScroll = true; # Add this if you prefer to scroll in the opposite direction
      };
  
      synaptics = {
        additionalOptions = ''
          Option "VertScrollDelta" "-100"
          Option "HorizScrollDelta" "-100"
        '';
        enable = true;
        # tapButtons = true; # TODO: revisit - this doesn't seem to work? 
        fingersMap = [ 0 0 0 ];
        buttonsMap = [ 1 3 2 ];
        twoFingerScroll = true;
      };
    };
  };
}
