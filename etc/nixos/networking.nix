{
  ... 
}:

{
  # Enable networking.
  networking = {
    networkmanager.enable = true;     # The recommend network manager (see also nmcli / nmtui)
    # wireless.enable = true;         # Needed only if networkmanager is not enabled
    # interfaceMonitor.enable = true; # TODO: needed?
    firewall = {
      enable = true;
      allowedTCPPorts = [
        # 80
      ];
      allowedUDPPorts = [ ];
      # allowPing = false;
    };
  };
}
