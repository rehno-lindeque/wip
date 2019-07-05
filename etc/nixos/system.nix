{ pkgs
, config
, lib
, ...
}:

with lib;

let
  resetPermissionsOnBoot = false;
in
{
  system = {
    activationScripts = optionalAttrs resetPermissionsOnBoot {
      # Make sure the main user has the desired directory structure
      myDirectories = stringAfter [ "stdio" "users" ] (''
          echo "Reset home directory permissions"
          mkdir -m 0700 -p ${config.users.users.me.home}/transient
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/config
          mkdir -m 0700 -p ${config.users.users.me.home}/projects/development
          mkdir -m 0700 -p ${config.users.users.me.home}/private
          mkdir -m 0700 -p ${config.users.users.me.home}/private-personal
          mkdir -m 0700 -p ${config.users.users.me.home}/private-share
          mkdir -m 0700 -p ${config.users.users.me.home}/private-share/syncthing
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share/documentation
          mkdir -m 0755 -p ${config.users.users.me.home}/public-share/video
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/transient
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/projects
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private-share
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/private-personal
          chown -R ${config.users.users.me.name}:${config.users.users.me.group} ${config.users.users.me.home}/public-share
        ''
        + optionalString config.services.syncthing.enable ''
          chown -R syncthing:syncthing ${config.users.users.me.home}/private-share/syncthing
          ${pkgs.acl}/bin/setfacl -R -m user:${config.users.users.me.name}:rx ${config.users.users.me.home}/private-share/syncthing
          ${pkgs.acl}/bin/setfacl -d -R -m user:${config.users.users.me.name}:rx ${config.users.users.me.home}/private-share/syncthing
          ${pkgs.acl}/bin/setfacl -m "u:syncthing:x" ${config.users.users.me.home}
          ${pkgs.acl}/bin/setfacl -m "u:syncthing:x" ${config.users.users.me.home}/private-share
          # ln -s /var/lib/syncthing ${config.users.users.me.home}/.config/syncthing
          # ${pkgs.acl}/bin/setfacl -R -m user:${config.users.users.me.name}:rx /var/lib/syncthing
          # ${pkgs.acl}/bin/setfacl -d -R -m user:${config.users.users.me.name}:rx /var/lib/syncthing
        '');

      # Mount directories for common media
      mediaDirectories = stringAfter [ "stdio" "users" ]
        ''
          echo "Reset media mount directory permissions"
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
    stateVersion = "18.03";

    # autoUpgrade = {
    #   channel = "https://nixos.org/channels/nixos-18.03";
    # };
    nixos.tags = [ "linux-${config.boot.kernelPackages.kernel.version}" ];
  };
}
