{
  ... 
}:

{
  # Enable networking.
  networking = {
    networkmanager.enable = true;     # The recommend network manager (see also nmcli / nmtui)
    # wireless.enable = true;         # Needed only if networkmanager is not enabled
    # interfaceMonitor.enable = true; # TODO: needed?
    # firewall.enable = true;         # TODO: needed?
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
