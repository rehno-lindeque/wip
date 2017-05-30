{
  pkgs
, ...
}:

{
  environment = {
    variables = {
    };
    systemPackages = with pkgs ; [
      # Hardware control
      # pmutils             # Handle suspend and resume
      # acpi                # Show battery status etc (Advanced Configuration and Power Interface)`
      # xscreensaver        # Screensavers

      # Networking
      nmcli-dmenu                      # Manage network connections via dmenu
      # networkmanagerapplet             # Manage network connections via nm-applet in trayer (xmonad)
    ];
  };
}

