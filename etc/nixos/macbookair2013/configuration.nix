{ pkgs
, ...
}:

{
  imports =
    [ # Include the results of the hardware scan.
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      # Configuration for all macbook hardware
      ../macbook/configuration.nix
    ];
  boot = {
    loader = {
      grub = {
        # From nixos-in-place.nix
        device = "/dev/sda";
        storePath = "/nixos/nix/store";
      };
    };
    initrd = {
      # From nixos-in-place.nix
      supportedFilesystems = [ "ext4" ];
      postDeviceCommands = ''
        mkdir -p /mnt-root/old-root ;
        mount -t ext4 /dev/sda6 /mnt-root/old-root ;
      '';
    };

    # TODO: is this still needed? macbookpro115 simply includes <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
    extraModulePackages =
      [
        config.boot.kernelPackages.broadcom_sta  # Broadcom wireless device
      ];
  };

  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
    "/old-root" = {
      device = "/dev/sda6";
      fsType = "ext4";
    };
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/17db0788-ce59-449f-8f44-35a41fc92277"; }
    ];

  # Enable networking.
  networking = {
    hostName = # Define your hostname. #gitignore
  };

  nix.maxJobs = 4;

  nixpkgs = {
    config = {
      chromium = {
        enablePepperFlash = true;
        enablePepperPDF = true;
        enableWideVine = true;     # needed for e.g. Netflix (DRM video)
      };
      packageOverrides = pkgs: {
        # Bluetooth stuff
        # bluez = pkgs.bluez5;
        # Enable thunderbolt
        # * https://github.com/mbbx6spp/mbp-nixos/blob/master/etc/nixos/configuration.nix#L194
        # Full support for Broadcom wireless modem (not sure if this is necessary?)
        # * https://github.com/cstrahan/mbp-nixos/blob/40c24909df8a6e19b7d3ff085de1c676ac54f879/configuration.nix#L68
        # * https://wireless.wiki.kernel.org/en/users/drivers/brcm80211 
        # Disabled for now due to the amount of recompilation required
        # linux_4_2 = pkgs.linux_4_2.override {
        #   extraConfig = ''
        #     BRCMFMAC_PCIE y
        #   '';
        #   # THUNDERBOLT m
        # };

      };
    };
  };

  services = {
    openssh.enable = false;  # Use this to start an sshd daemon (to enable remote login)

    # # Power control events (power/sleep buttons, notebook lid, power adapter etc)
    # # See also https://github.com/ajhager/airnix/blob/master/configuration.nix#L91
    # acpid =
    #   {
    #     enable = true;
    #     # lidEventCommands =
    #     #   # TODO: I think that this may not work on macbookpro11x due to suspend problems?
    #     #   #       I.e. $ ls /proc/acpi/button/lid/LID0/state
    #     #   #       (On the other hand, emperically this seems to work automatically on macbookpro11x with a patch applied. How do we test?)
    #     #   ''
    #     #   LID_STATE=/proc/acpi/button/lid/LID0/state
    #     #   if [ $(/run/current-system/sw/bin/awk '{print $2}' $LID_STATE) = 'closed' ]; then
    #     #     systemctl suspend
    #     #   fi
    #     #   '';
    #   };

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
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess"
                           SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess"
                           '';
                    destination = "/etc/udev/rules.d/20-hw1.rules";
                  };
      in [ hw1 ];
  };

  users.users = {
    me = {
      name = # "me"; #gitignore
      description = # "Name Surname"; #gitignore
    };
  };
}

