{
  pkgs
, ...
}:

{
  services = {
    openssh.enable = false;  # Use this to start an sshd daemon (to enable remote login)

    # Power control events (power/sleep buttons, notebook lid, power adapter etc)
    # See also https://github.com/ajhager/airnix/blob/master/configuration.nix#L91
    acpid =
      {
        enable = true;
        lidEventCommands =
          # TODO: I think that this may not work on macbookpro11x due to suspend problems?
          #       I.e. $ ls /proc/acpi/button/lid/LID0/state
          #       (On the other hand, emperically this seems to work automatically on macbookpro11x with a patch applied. How do we test?)
          ''
          LID_STATE=/proc/acpi/button/lid/LID0/state
          if [ $(/run/current-system/sw/bin/awk '{print $2}' $LID_STATE) = 'closed' ]; then
            systemctl suspend
          fi
          '';
      };

    xserver = {
      videoDrivers = [ "intel" "nouveau" ];
    };

    # Custom Hardware (TODO: Modularize)
    # Based on the example at https://github.com/NixOS/nixpkgs/issues/10646#issuecomment-183131248
    udev.packages =
      let hw1 = pkgs.writeTextFile
                  {
                    name = "hw1-udev-rules";
                    text = ''
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
                           '';
                    destination = "/etc/udev/rules.d/20-hw1.rules";
                  };
      in [ hw1 ];
  };
}
