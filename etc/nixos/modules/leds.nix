{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.leds;
in
{
  options = {
    hardware.leds = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Grant access to LED devices (typically keyboard LEDs and backlight) to the given group.
          By default, an leds group is created for this purpose.
        '';
      };
      group = mkOption {
        type = types.str;
        default = "leds";
        example = "users";
        description = ''
          Grant access to LED devices to users in this group.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraGroups = optionalAttrs (cfg.group == "leds") (lib.singleton {
      name = "leds";
    });

    services.udev.packages =
      lib.singleton (pkgs.writeTextFile {
        name = "led-udev-rules";
        destination = "/etc/udev/rules.d/61-leds.rules";
        # Add group permission for devices in the leds subsystem.
        # See https://unix.stackexchange.com/a/202870/140673.
        text = ''
          SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp -R ${cfg.group} /sys%p", RUN+="${pkgs.coreutils}/bin/chmod -R g=u /sys%p"
          SUBSYSTEM=="leds", ACTION=="change", ENV{TRIGGER}!="none", RUN+="${pkgs.coreutils}/bin/chgrp -R ${cfg.group} /sys%p", RUN+="${pkgs.coreutils}/bin/chmod -R g=u /sys%p"
        '';
      });
  };
}
