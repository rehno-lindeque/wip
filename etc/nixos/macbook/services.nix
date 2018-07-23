{
  pkgs
, lib
, config
, ...
}:

{
  services = {
    dbus.enable = true;
    locate.enable = true;
    # mpd.enable = true;    # music player daemon
    upower.enable = true;

    # TODO: 17.09
    # fstrim.enable = true;

    # Advanced Power Management for Linux
    tlp =
      # Turns on power saving features usually used on battery for AC power as well.
      # This can be useful for keeping you macbook pro running cool at the cost of some performance.
      let aggressivePowerSavingOnAC = true;
      in
      {
        enable = true;
        extraConfig =
          # Select a CPU frequency scaling governor. 
          # Intel Core i processor with intel_pstate driver:
          #   powersave(*), performance
          # Older hardware with acpi-cpufreq driver:
          #   ondemand(*), powersave, performance, conservative
          # (*) is recommended.
          # Hint: use tlp-stat -p to show the active driver and available governors.
          # Important:
          #   You *must* disable your distribution's governor settings or conflicts will
          #   occur. ondemand is sufficient for *almost all* workloads, you should know
          #   what you're doing!
          # ---
          # See also
          # * http://linrunner.de/en/tlp/docs/tlp-configuration.html#scaling

          # TODO: do we have the intel_pstate driver?

          ''
          CPU_SCALING_GOVERNOR_ON_AC=powersave
          CPU_SCALING_GOVERNOR_ON_BAT=powersave
          '' +
          # Minimize number of used CPU cores/hyper-threads under light load conditions
          # I've turned this to 1 because I prefer my macbook running cool
          ''
          SCHED_POWERSAVE_ON_AC=${if aggressivePowerSavingOnAC then "1" else "0"}
          '' +
          # Include listed devices into USB autosuspend even if already excluded
          # by the driver or WWAN blacklists above (separate with spaces).
          # Use lsusb to get the ids.
          # ---
          # Note that apple trackpad does have explicit autosuspend support.
          # * See http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=88da765f4d5f59f67a7a51c8f5d608a836b32133
          ''
          USB_WHITELIST="05ac:0274"
          '' +
          # PCI Express Active State Power Management (PCIe ASPM):
          #   default, performance, powersave
          ''
          PCIE_ASPM_ON_AC=${if aggressivePowerSavingOnAC then "powersave" else "performance"}
          '' +
          # Radeon graphics clock speed (profile method): low, mid, high, auto, default;
          # auto = mid on BAT, high on AC; default = use hardware defaults.
          # (Kernel >= 2.6.35 only, open-source radeon driver explicitly)
          # ---
          # I've turned this to low on AC because my graphics card tends to warm up more than I like on AC, but others may prefer mid or auto
          ''
          RADEON_POWER_PROFILE_ON_AC=${if aggressivePowerSavingOnAC then "low" else "mid"}
          '' +
          # Radeon dynamic power management method (DPM): battery, balanced, performance
          # (Kernel >= 3.11 only, requires boot option radeon.dpm=1)
          # ---
          # I've turned this to battery because my graphics card tends to warm up more than I like on AC, but other may prefer to se this to balanced or performance.
          # * Note that http://linrunner.de/en/tlp/docs/tlp-configuration.html#graphics only lists battery and performance as options,
          #   however https://wiki.archlinux.org/index.php/ATI#Powersaving says that balanced should also be possible which appears to be correct.
          ''
          RADEON_DPM_STATE_ON_AC=${if aggressivePowerSavingOnAC then "battery" else "balanced"}
          ''
                    
          # TODO:
          
          # Set Intel P-state performance: 0..100 (%)
          # Limit the max/min P-state to control the power dissipation of the CPU.
          # Values are stated as a percentage of the available performance.
          # Requires an Intel Core i processor with intel_pstate driver.
          #CPU_MIN_PERF_ON_AC=0
          #CPU_MAX_PERF_ON_AC=100
          #CPU_MIN_PERF_ON_BAT=0
          #CPU_MAX_PERF_ON_BAT=30
          ;
      };

    xserver = {
      xkbVariant = "mac";
      /* vaapiDrivers = [ pkgs.vaapiIntel ]; */

      # Customize the trackpad
      # * This is an alternative to the synaptics driver
      # * Unique features:
      #   - 3 finger swipe gesture
      #   - pinch gesture
      #   - rotate gesture
      # * Documentationut
      #   https://github.com/BlueDragonX/xf86-input-mtrack#xf86-input-mtrack
      multitouch =
       {
         enable = true;
         additionalOptions = 
           # There is conflicting information the best FingerHigh/FingerLow
           # For now we use the settings from https://wiki.archlinux.org/index.php/MacBookPro11,x#input-mtrack
           # However I bumpted FingerLow up from 1 because it kept clicking the screen while I was typing despite having ignoreThumb and ignorePalm activated
           ''
           Option "FingerHigh" "7"
           Option "FingerLow" "6"
           '' +
           # Thumbs touching the pad while typing gets very distracting
           # https://wiki.archlinux.org/index.php/MacBookPro11,x#input-mtrack
           ''
           Option "IgnoreThumb" "true"
           '' +
           # The remainder of these options are unreviewed, they come from https://wiki.archlinux.org/index.php/MacBookPro11,x#input-mtrack
           # minus settings already provided. They appear immitate what OSX does
           (lib.optionalString config.services.xserver.multitouch.tapButtons
             ''
             Option          "TapButton1" "1"
             Option          "TapButton2" "3"
             Option          "TapButton3" "2"
             Option          "TapButton4" "0"
             ''
           ) +
           ''
           Option          "Sensitivity" "0.64"
           Option          "DisableOnPalm" "true"
           Option          "ButtonMoveEmulate" "false"
           Option          "ButtonIntegrated" "true"
           Option          "ClickTime" "25"
           Option          "BottomEdge" "30"
           Option          "SwipeLeftButton" "8"
           Option          "SwipeRightButton" "9"
           Option          "SwipeUpButton" "0"
           Option          "SwipeDownButton" "0"
           Option          "ScrollDistance" "75"
           Option          "VertScrollDelta" "-111"
           Option          "HorizScrollDelta" "-111"
           '';
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
         # buttonsMap = [ 1 3 2 ];
         ignorePalm = true;
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
  
    # Power control events (power/sleep buttons, notebook lid, power adapter etc)
    # See also https://github.com/ajhager/airnix/blob/master/configuration.nix#L91
    # Alternatively https://bbs.archlinux.org/viewtopic.php?pid=1495332#p1495332
    acpid = {
      enable = true;
      # lidEventCommands =
      #   let
      #     lockCommand =
      #       # When using slim:
      #       # ''${pkgs.su}/bin/su ${config.users.users.me.name} -c ${pkgs.slim}/bin/slimlock ;''
      #       # When using lightdm:
      #       # ''${pkgs.su}/bin/su ${config.users.users.me.name} -c XDG_SEAT_PATH="/org/freedesktop/DisplayManager/Seat0" ${pkgs.lightdm}/bin/dm-tool lock ;'';
      #   in ''
      #     LID="/proc/acpi/button/lid/LID0/state"
      #     state=`cat $LID | ${pkgs.gawk}/bin/awk '{print $2}'`
      #     case "$state" in
      #       *close*)
      #           # {pkgs.util-linux}/bin/logger -t lid-handler "attempt to close lid ($state)" ;
      #           ${lockCommand}
      #           ;;
      #       *)
      #           #{pkgs.util-linux}/bin/logger -t lid-handler "Failed to detect lid state ($state)" ;
      #           ;;
      #     esac
      #     '';
    };
  };

  # systemd = {
  #   packages = [ pkgs.arch-linux-macbook.wakeup ];
  #   units."macbook-wakeup.service".wantedBy = [ "multi-user.target" ];
  # };
}
