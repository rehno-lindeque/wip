{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.macbookpro2017;
in {
  options = with lib; {
    profiles.macbookpro2017 = {
      enable = mkEnableOption ''
        Whether to enable my laptop configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    profiles = {
      common.enable = true;
      workstation.enable = true;
      personalized = {
        enable = true;
        enableSoftware = true;
        enableProblematicSoftware = true;
        enableHome = true;
      };
      preferences.enable = true;
      playground.enable = true;
    };
    circuithubConfigurations.developerWorkstation.enable = true;

    # Unfortunately systemd-boot does not appear to work with LUKS when kernel version > 5.4
    # Instead we use grub with LUKS support enabled
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiInstallAsRemovable = true;
      efiSupport = true;

      # Limit the number of entries for now due to low disk space in /boot
      configurationLimit = 3;

      # LUKS support
      enableCryptodisk = true;
    };

    # On this system / and /nix/store are on an encrypted LUKS device
    boot.initrd.luks.devices = {
      nixosroot.device = "/dev/disk/by-uuid/95a903c1-2a2f-44b9-90c2-cd810ea18cd4";
    };

    boot.kernelParams =
      # Fixes a backlight issue when using amdgpu due to a patch merged in linux since 6.1.4
      # (The patch in question is "drm/amdgpu: Don't register backlight when another backlight should be used")
      lib.optional (config.boot.kernelPackages.kernelAtLeast "6.1.4") "acpi_backlight=native";

    environment.persistence."/nix/persistent" = {
      directories = [
        # Contains uuid and gid map
        "/var/lib/nixos"
      ];

      users.me = let
        permissions = {
          user = "me";
          group = "users";
        };
      in {
        home = "/home/new-me";
        directories = [
          # Retain all of my home config for the time being
          ".config"

          # Retain ssh keys for this computer
          {
            directory = ".ssh";
            mode = "0700";
          }

          # Retain trusted nix settings and repl history
          ({
              directory = ".local/share/nix"; # repl-history trusted-settings.json
            }
            // permissions)

          # Retain neovim undo files
          ({directory = ".local/share/nvim";} // permissions)

          # ".cache/nix" (TODO)

          # Retain my xmonad configuration and build outputs (TODO: move to .local/.../xmonad)
          ".xmonad"
        ];

        files = [
          # Retain aws credentials
          {
            file = ".aws/credentials";
            parentDirectory = {mode = "u=rwx,g=xr,o=";};
          }
        ];
      };
    };

    fileSystems = {
      "/" = {
        # Found under /dev/disk/by-label/nixosroot
        device = "/dev/disk/by-uuid/f1e38edd-d1ae-47fe-b7cb-aaaafb0f2b45";
        fsType = "ext4";
      };

      # Impermanent home directory
      "/home/new-me" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "size=4G"
          "mode=764"
          # Unavailable due to neededForBoot
          # "uid=me"
          # "gid=users"
        ];
        # Needed due to undocumented race condition in impermanence
        # See https://github.com/nix-community/impermanence/pull/109#issuecomment-1506538692
        neededForBoot = true;
      };

      "/boot" = {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
      };
    };

    swapDevices = [
      {device = "/dev/disk/by-label/nixosswap";}
    ];

    # Hardware acceleration
    hardware.graphics.enable = true;

    # A redistributable flag normally provided by not-detected.nix
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    networking.hostName = "macbookpro2017";

    networking.interfaces.wlp4s0 = {
      # macAddress = "a4:5e:60:e8:05:4f; # ip link show wlp4s0
    };
    networking.interfaces.tailscale0 = {
      ipv4.addresses = [
        {
          address = "100.102.213.117";
          prefixLength = 32;
        }
      ];
    };

    # Cloud password manager
    programs._1password-gui.enable = true;

    programs.llm.enable = true;
    programs.llm.agents.advisor = {
      instructions = ''
        Your role is super-intelligent code editor. Expect code snippets
        accompanied by transcribed speech. Respond briefly via bite-sized
        extremely concise answers.
      '';
      relay = "UNIX-CONNECT:/run/mymux/llm-advisor.sock";
    };

    # GUI for asking for ssh password (for code-cursor / vscode)
    programs.ssh.enableAskPassword = true;

    # Automatically handle standalone screen when docked
    services.autorandr.enable = true;

    # Run xmonad on this computer
    services.displayManager.defaultSession = "none+xmonad";

    # Enable the laptop trackpad and disable annoyingly sensitive trackpad tap during typing
    services.libinput.enable = true;
    services.libinput.touchpad.disableWhileTyping = true;

    # Don't power off when the power button is hit
    services.logind.powerKey = "lock";

    # Fan control for the macbook pro
    services.mbpfan.settings.general = {
      # Run the fan a little bit more aggressively
      # I do this because my cpu usage tends to be quite spiky
      max_temp = 78;
      min_fan1_speed = 3000;
    };

    # Multiplex IDE, voice transcription, LLM, etc communication
    services.mymux.enable = true;

    # Local speech recognition for use with voxinput
    services.whisper.enable = true;
    services.whisper.port = 8082;
    services.whisper.inferencePath = "/v1/audio/transcriptions";
    services.whisper.model = pkgs.fetchurl {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/5359861c739e955e79d9a303bcbc70fb988958b1/ggml-tiny.en-q8_0.bin";
      sha256 = "sha256-W8KzhgqhUaTG57sJXh/M588Sx7Agygjc7AxtAYu33ZQ=";
    };

    # Input emulation and automation
    services.dotool.enable = true;

    # Run lightdm on this computer
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.windowManager.xmonad.enable = true;
    services.xserver.windowManager.xmonad.extraPackages = haskellPackages: [
      # Note that xmonad-extras is frequently broken, but xmonad-contrib is more stable
      haskellPackages.xmonad-contrib
    ];

    # System first initialized at release 22.05
    system.stateVersion = "22.05";
    home-manager.users.me.home.stateVersion = "22.05";

    # Preserve the old home directory
    users.users.me.home = lib.mkForce "/home/new-me";

    # Extra software packages exclusively used on this system
    users.users.me.packages = [
      # Program launcher that works with xmonad
      pkgs.dmenu

      # Terminal
      pkgs.sakura

      # IDE
      pkgs.code-cursor
    ];

    users.users.me.extraGroups = [
      # Allow communications with dotoold
      "dotool"
    ];
  };
}
