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
          mkdir -m 0700 -p ${config.users.users.me.home}/public/documentation
          mkdir -m 0700 -p ${config.users.users.me.home}/public/video
          mkdir -m 0700 -p ${config.users.users.me.home}/personal
          mkdir -m 0700 -p ${config.users.users.me.home}/transient
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/public
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/personal
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/transient
        '';

      # TODO: make sure /tmp/ram exists?
    };

    # The NixOS release to be compatible with for stateful data such as databases.
    stateVersion = "17.03";
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
