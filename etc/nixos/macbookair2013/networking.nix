{
  ... 
}:

{
  # Enable networking.
  networking = {
    hostName = # Define your hostname. #gitignore
    # networkmanager.enable = true; # TODO: an alternative to wireless.enable?
    wireless.enable = true;
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
