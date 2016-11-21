{
  config
, pkgs
, ... 
}:

{
  # User account.
  # * Set a password using
  #   $ useradd -m $ME ; passwd $ME
  users =
   {
      # defaultUserShell = "/run/current-system/sw/bin/gnome-terminal";
      users =
        {
          me =
            {
              group = "users";
              uid = 105;
              createHome = true;
              home = "/home/${config.users.users.me.name}";
              extraGroups =
                [
                  "wheel"          # TODO: allows your user to access stored passwords?
                                   # * you need wheel in order to use sudo for example
                  "audio"          # ?
                  "video"          # ?
                  "scanner"        # Group created by hardware.sane
                  # "keyboard"     # Used by (custom) actkbd user service
                  "networkmanager" # Needed to allow connecting to the network
                  "mysql"          # Allows you to use the running mysql service via your user (usefull for software development)
                                   # * you will see that the /var/mysql/* files that are created belongs to the mysql user & group
                  # "postgres"       # Allows you to use the running postgres service via your user (usefull for software development)
                  # "psql"           # Postgres sql
                ];
              isSystemUser = false;
              useDefaultShell = true;
              # TODO: remove - there's probably no reason to put our own pub key in the authorized keys
              # openssh.authorizedKeys.keyFiles = [ "${config.users.users.me.home}/.ssh/id_rsa.pub" ];
            };
        };
    };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
