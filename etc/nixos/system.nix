{
  config
, lib
, ... 
}:

with lib;

{
  system = {
    activationScripts = {
      # Make sure the main user has the desired directory structure
      myDirectories = stringAfter [ "stdio" "users" ]
        ''
          mkdir -m 0700 -p ${config.users.users.me.home}/transient
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/config
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/development
          mkdir -m 0700 -p ${config.users.users.me.home}/private
          mkdir -m 0700 -p ${config.users.users.me.home}/private-personal
          mkdir -m 0700 -p ${config.users.users.me.home}/private-share
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share/documentation
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share/video
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/transient
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private-share
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private-personal
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/public-share
        '';

      # Mount directories for common media
      mediaDirectories = stringAfter [ "stdio" "users" ]
        ''
          mkdir -m 0755 -p /media/iso
          mkdir -m 0755 -p /media/usb
          mkdir -m 0755 -p /media/usb2
          mkdir -m 0755 -p /media/sdcard
          mkdir -m 0700 -p /media/private
          chown ${config.users.users.me.name}:${config.users.users.me.group} /media/iso
        '';

      # TODO: make sure /tmp/ram exists?
    };

    # The NixOS release to be compatible with for stateful data such as databases.
    stateVersion = "17.09";

    # autoUpgrade = {
    #   channel = "https://nixos.org/channels/nixos-17.09";
    # };
  };
}
