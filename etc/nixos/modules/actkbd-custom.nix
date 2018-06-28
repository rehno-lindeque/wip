# This is not the service itself, but a modification to the actkbd service
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.actkbd;
in
{
  options = {
    services.actkbd = {
      user = mkOption {
        type = types.str;
        default = "actkbd";
        description = ''
          The user to run the daemon as.
          An actkbd user will be created by default if none is specified.
          This can be your user name, if you wish to grant it your personal priviledges.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "actkbd";
        description = ''
          The group to run the daemon as.
          A actkbd group will be created by default if none is specified.
          This can be your user name, if you wish to grant it your personal priviledges.
        '';
      };
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ "input" ];
        description = ''
          TODO
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers = optionalAttrs (cfg.user == "actkbd") (lib.singleton {
      name = "actkbd";
      group = cfg.group;
      extraGroups = cfg.extraGroups;
    });

    users.extraGroups = optionalAttrs (cfg.group == "actkbd") (lib.singleton {
      name = "actkbd";
    });

    systemd.services."actkbd@" = {
      after = [ "graphical.target" "sound.target" "systemd-backlight@leds:smc::kbd_backlight.service" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = cfg.extraGroups;
      };
    };
  };
}
