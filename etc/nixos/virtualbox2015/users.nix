{ 
  ... 
}:

{
  users.users = {
    me = {
      name = # "me"; #gitignore
      home = # "/home/me"; #gitignore
      description = # "Name Surname"; #gitignore
    };
    /* circuithub #gitignore */
    /*   = { */
    /*   name = "circuithub"; # ""; #gitignore */
    /*   home = "/home/circuithub"; # ""; #gitignore */
    /*   description = "CircuitHub PostgreSQL user"; # "Name Surname"; #gitignore */
    /*   extraGroups = */
    /*     [ */
    /*       "postgres"       # Allows you to use the running postgres service via your user (usefull for software development) */
    /*       "psql"           # Postgres sql */
    /*     ]; */
    /* }; */
  };
}

# This is a [modeline](http://stackoverflow.com/a/3958516/167485) for vim that can make editing this file easier inside vim
# It is probably not necessary if you have settings for .nix files already defined, see :help auto-setting (TODO: better nix vim settings)
# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent syntax=nix nocompatible :
