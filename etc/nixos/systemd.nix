{ 
  pkgs
, lib
, config
, ...
}:

let
  # Enable to use this only with a specific device
  # useSpecifiedDevice = false;
  # keyboardDevice = "usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad-event-kbd";
  # keyboardAttr = "Apple Inc. Apple Internal Keyboard / Trackpad";
  keyboardDevice = "usb-TrulyErgonomic.com_Truly_Ergonomic_Computer_Keyboard-event-kbd";
  keyboardAttr = "TrulyErgonomic.com Truly Ergonomic Computer Keyboard";
in
{
  # In order to get actkbd to work properly it was necessary to create a user service for it
  # See
  # * http://unix.stackexchange.com/a/67527/140673
  # * https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/hardware/actkbd.nix

  # To see whether actkbd-user is running:
  #   $ systemctl status --user actkbd-user.service

  # To find keyboard devices:
  #   $ cat /proc/bus/input/devices 
  # or alternatively: 
  #   $ ls /dev/input/by-id
  # To find key stroke codes:
  #   $ actkbd -s -d /dev/input/by-id/$mykbd

  # # systemd.services.actkbd-user =
  # /* systemd.user.services.actkbd-user = */
  # systemd.user.services."actkbd-user@" =
  #   {
  #     /* description = "actkbd user service"; */
  #     enable = true;
  #     restartIfChanged = true;
  #     # wantedBy = [ "multi-user.target" ]; 
  #     # wantedBy = [ "default.target" ];
  #     # after = [];
  #     unitConfig =
  #       {
  #         Description = "actkbd (user service) on %I";
  #         ConditionPathExists = "%I";
  #       };
  #     serviceConfig =
  #       {
  #         Type = "forking";
  #         # # User = "root";
  #         # User = "me";
  #         RemainAfterExit = "yes";
  #         Restart = "always";
  #         ExecStart =
  #          let 
  #            configFile = pkgs.writeText "actkbd.conf"
  #              # 113:key:exec:${pkgs.alsaUtils}/bin/amixer -q set Master toggle
  #              # 114:key,rep:exec:${pkgs.alsaUtils}/bin/amixer -q set Master 5-
  #              # 115:key,rep:exec:${pkgs.alsaUtils}/bin/amixer -q set Master 5+
  #              # 224:key,rep:exec:${pkgs.light}/bin/light -U 4
  #              # 225:key,rep:exec:${pkgs.light}/bin/light -A 4
  #              # 229:key,rep:exec:${pkgs.kbdlight}/bin/kbdlight up
  #              # 230:key,rep:exec:${pkgs.kbdlight}/bin/kbdlight down
  #              # 127:key,rep:exec:${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              # 118:key,rep:exec:${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              # 58:key,rep:exec:${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              # 126:key,rep:exec:${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              # 60:key,rep:exec:${pkgs.feh}/bin/feh -NZx -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              ''
  #              64:key,rep:exec:${pkgs.feh}/bin/feh -NZ -g 640x480 /home/me/projects/config/dotfiles/cheatsheets/workman_keyboard_layout.png
  #              '';
  #            startActkbdDaemon = pkgs.writeScript "start-actkbd"
  #              ''
  #               #!/bin/sh
  #               . ${config.system.build.setEnvironment}
  #               ${pkgs.actkbd}/bin/actkbd -v9 -sx -D -c ${configFile} -d $1
  #              '';
  #            # To activate on a specific device:
  #            # ${pkgs.actkbd}/bin/actkbd -v9 -sx -D -c ${configFile} -d /dev/input/by-id/${keyboardDevice}
  #          in
  #            /* ''${pkgs.actkbd}/bin/actkbd -v9 -sx -D -c ${configFile} -d %I''; */
  #            /* ''${pkgs.actkbd}/bin/actkbd -v9 -sx -D -c ${configFile} -d /dev/input/by-id/${keyboardDevice}''; */
  #            ''${startActkbdDaemon} %I'';
  #            /* ''${startActkbdDaemon} /dev/input/by-id/${keyboardDevice}''; */
  #       };
  #   };

  # services.udev.packages = lib.singleton
  #   ( pkgs.writeTextFile
  #       {
  #         name = "actkbd-user-udev-rules";
  #         destination = "/etc/udev/rules.d/61-actkbd-user.rules";
  #         text =
  #           /* '' */
  #           /* ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-9]*", ENV{ID_INPUT_KEY}=="1", MODE="0666", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="actkbd-user@$env{DEVNAME}.service" */
  #           /* ''; */
  #           ''
  #           ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-9]*", ENV{ID_INPUT_KEY}=="1", MODE="0666", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="actkbd-user@$env{DEVNAME}.service"
  #           '';
  #           /* '' */
  #           /* ACTION=="add", SUBSYSTEM=="input", KERNEL=="event[0-9]*", MODE="0666", ENV{ID_INPUT_KEY}=="1", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="actkbd-user.service" */
  #           /* ''; */
  #           # SUBSYSTEM=="device", SYSFS{idVendor}=="Apple_Inc." , SYSFS{idProduct}=="Apple_Internal_Keyboard___Trackpad", MODE="666"
  #           # KERNEL=="event11", SUBSYSTEM=="input", MODE="0666"
  #           # SUBSYSTEM=="input", SYSFS{idVendor}=="Apple_Inc." , SYSFS{idProduct}=="Apple_Internal_Keyboard___Trackpad", MODE="0666"
  #           # SUBSYSTEM=="input", ATTRS{idVendor}=="Apple_Inc.", ATTRS{idProduct}=="Apple_Internal_Keyboard___Trackpad", MODE="0666"
  #           # ''
  #           # SUBSYSTEM=="input", ATTRS{name}=="${keyboardAttr}", MODE="0666"
  #           # '';
  #           /* '' */
  #           /* ACTION=="add", SUBSYSTEM=="input", KERNEL="event[0-9]*", ATTRS{name}=="${keyboardAttr}", MODE="0666", ENV{ID_INPUT_KEY}=="1", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="actkbd-user.service" */
  #           /* ''; */
  #       }
  #   );
 
}
