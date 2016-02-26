{
  ...
}:

{
  boot = {
    initrd = {
      kernelModules = [ "fbcon" ];  # Make it pretty (support fonts in the terminal)
    };
    # Start a root shell if something goes wrong during stage 1 of the boot process (there is no authentiatcation for the root shell)
    kernelParams = [ "boot.shell_on_fail" ];
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
