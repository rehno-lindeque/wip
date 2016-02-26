{
  pkgs
, ...
}:

{
  services = {
    acpid.enable = true;  # Power control events (power/sleep buttons, notebook lid, power adapter etc)
    dbus.enable = true;   # TODO: ?
    locate.enable = true;
    mpd.enable = true;    # TODO: ?
    upower.enable = true; # TODO: ?

    xserver = {
      xkbVariant = "mac";
      videoDrivers = [ "intel" "nouveau" ];
      vaapiDrivers = [ pkgs.vaapiIntel ];

      # Customize the trackpad
      # * This is an alternative to the synaptics driver
      # * Unique features:
      #   - 3 finger swipe gesture
      #   - pinch gesture
      #   - rotate gesture
      # * Documentation
      #   https://github.com/BlueDragonX/xf86-input-mtrack#xf86-input-mtrack
      multitouch =
       {
         enable = true;
         # additionalOptions = 
         #   ''
         #     Option "Sensitivity" "1.25"
         #     Option "FingerHigh" "5"
         #     Option "FingerLow" "4"
         #     Option "IgnoreThumb" "true"
         #     Option "TapButton4" "0"
         #     # Option "ClickFinger1" "1"
         #     # Option "ClickFinger2" "3"
         #     # Option "ClickFinger3" "3"
         #     Option "ButtonMoveEmulate" "true"
         #     Option "ButtonIntegrated" "true"
         #     Option "ClickTime" "25"
         #     Option "BottomEdge" "5"
         #     Option "SwipeLeftButton" "8"
         #     Option "SwipeRightButton" "9"
         #     Option "SwipeUpButton" "0"
         #     Option "SwipeDownButton" "0"
         #     Option "ScaleDistance" "150"
         #     Option "ScaleUpButton "12"
         #     Option "ScaleDownButton "13"
         #     Option "RotateDistance "150"
         #     Option "RotateLeftButton "14"
         #     Option "RotateRightButton "15"
         #     Option "ScrollDistance" "30"
         #     Option "ScrollUpButton" "4"
         #     Option "ScrollDownButton" "5"
         #     Option "ScrollLeftButton" "6"
         #     Option "ScrollRightButton" "7"
         #     Option "ThumbSize" "35"
         #     Option "PalmSize" "55"
         #     Option "DisableOnThumb" "false"
         #     Option "DisableOnPalm" "true"
         #     Option "SwipeDistance" "1000"
         #     Option "AccelerationProfile" "2"
         #     Option "ConstantDeceleration" "2.0"
         #     Option "AdaptiveDeceleration" "2.0"
         #     # Option "ScrollSmooth" "true"        # This seems like it might be buggy
         #   '';
         # buttonsMap = [ 1 3 2 ];
         # ignorePalm = true;
         # invertScroll = false;
         # tapButtons = true;
       };

      # Customize the trackpad
      # * This is an alternative to mtrack (multitouch), which we're using.
      # * Unique features:
      #   - circular scroll
      #   - coasting
      # * Exhaustive documentation
      #   $ man synaptics
      # * See also
      #   https://wiki.archlinux.org/index.php/Touchpad_Synaptics
      # * Find out about device capabilities
      #   $ xinput -list | grep pointer
      #   $ xinput list-props "bcm5974"
      # synaptics =
      #   {
      #     enable = true;
      #     additionalOptions = ''
      #       Option "VertScrollDelta" "75"
      #       Option "HorizScrollDelta" "75"
      #       # Option "CircScrollTrigger" "2"
      #       Option "VertEdgeScroll" "on"
      #     '';
      #     tapButtons = true;
      #     fingersMap = [ 1 2 2 ];
      #     buttonsMap = [ 1 3 2 ];
      #     twoFingerScroll = true;
      #     accelFactor = "0.1"; #gitignore
      #     minSpeed = "1.5";    #gitignore
      #     maxSpeed = "2.0";    #gitignore
      #     palmDetect = true;
      #   };

      # TODO: what does this do? https://github.com/cstrahan/mbp-nixos/blob/master/configuration.nix#L46
      # displayManager.sessionCommands = ''
      #   ${pkgs.xorg.xset}/bin/xset r rate 220 50
      #   if [[ -z "$DBUS_SESSION_BUS_ADDRESS" ]]; then
      #     eval "$(${pkgs.dbus.tools}/bin/dbus-launch --sh-syntax --exit-with-session)"
      #     export DBUS_SESSION_BUS_ADDRESS
      #   fi
      # '';
    };
  
    # Change screen brightness / colors based on time of day
    # redshift = {
    #   enable = true;
    #   # latitude = "";
    #   # longitude = "";
    #   temperature = {
    #     day = 5500;
    #     night = 2300;
    #   };
    # };
  
    # Activate these if you're not using xmonad to control media keys
    actkbd = {
      enable = true;
      bindings = [
        # Media keys
        { keys = [ 113 ]; events = [ "key" ]; command = "${pkgs.alsaUtils}/bin/amixer -q set Master toggle"; }
        { keys = [ 114 ]; events = [ "key" "rep" ]; command = "${pkgs.alsaUtils}/bin/amixer -q set Master 5-"; }
        { keys = [ 115 ]; events = [ "key" "rep" ]; command = "${pkgs.alsaUtils}/bin/amixer -q set Master 5+"; }
        # Screen backlight
        { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -U 4"; }
        { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -A 4"; }
        # Keyboard backlight
        { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up"; }
        { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down"; }
      ];
    };
  };
}
