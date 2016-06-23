{
  config
, lib
, ... 
}:

with lib;

{
  system = {
    # Make sure the main user has the desired directory structure
    activationScripts = {
      myDirectories = stringAfter [ "stdio" "users" ]
        ''
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/config
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/development
          chown ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects
          chown ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects/config
          chown ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects/development
        '';
    };
    # The NixOS release to be compatible with for stateful data such as databases.
    stateVersion = "16.03";
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
