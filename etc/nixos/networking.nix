{
  ... 
}:

{
  # Enable networking.
  networking = {
    networkmanager.enable = true;     # The recommend network manager (see also nmcli / nmtui)
    # wireless.enable = true;         # Needed only if networkmanager is not enabled
    firewall = {
      enable = true;
      allowedTCPPorts = [
        # 80
      ];
      allowedUDPPorts = [ ];
      # allowPing = false;
    };

    wlanInterfaces = {
      "wlan" = {
        device = "wlp4s0";
        # mac = "7e:fa:03:98:8d:f6";
        mac = "12:fc:80:50:d8:8e";
      };
      # For playing with wireshark to monitor wifi traffic
      # "wlan-monitor" = {
      #   device = "wlp4s0";
      #   type = "monitor";
      # };
    };
  };
}
