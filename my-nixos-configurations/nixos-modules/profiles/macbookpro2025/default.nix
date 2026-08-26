{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.macbookpro2025;
  asahiAudioControl = pkgs.writeShellScript "asahi-audio-control" ''
    set -eu

    refresh_waybar() {
      ${lib.getExe' pkgs.procps "pkill"} -RTMIN+8 waybar >/dev/null 2>&1 || true
    }

    set_default_sink() {
      command="$1"
      shift
      ${lib.getExe' pkgs.wireplumber "wpctl"} "$command" "$sink_id" "$@" || true
      refresh_waybar
    }

    audio_unavailable() {
      ${lib.getExe pkgs.jq} -cn --arg muted "$1" '{text: $muted, tooltip: "No default audio sink", class: "muted"}'
    }

    sink_id="@DEFAULT_AUDIO_SINK@"

    case "$1" in
      raise) set_default_sink set-volume 0.1+ -l 1.0 ;;
      lower) set_default_sink set-volume 0.1- ;;
      raise-small) set_default_sink set-volume 0.05+ -l 1.0 ;;
      lower-small) set_default_sink set-volume 0.05- ;;
      mute) set_default_sink set-mute toggle ;;
      status)
        if ! volume="$(${lib.getExe' pkgs.wireplumber "wpctl"} get-volume "$sink_id" 2>/dev/null)"; then
          audio_unavailable "$3"
          exit 0
        fi

        printf '%s\n' "$volume" | ${lib.getExe pkgs.jq} -cRn --arg audio "$2" --arg muted "$3" '
          input
          | capture("Volume: (?<volume>[0-9.]+)(?<muted> \\[MUTED\\])?")
          | (.volume | tonumber * 100 | round) as $percent
          | if .muted == null then
              {text: ($audio + " " + ($percent | tostring) + "%"), class: "normal"}
            else
              {text: $muted, class: "muted"}
            end
        '
        ;;
    esac
  '';
  waybarIcons = {
    audio = "";
    audioMuted = "󰝟";
    backlight = "󰃠";
    battery = "󰁹";
    batteryCharging = "󰂄";
    batteryPlugged = "󰚥";
    screenshot = "󰹑";
    ethernet = "󰈀";
    link = "󰈁";
    networkOffline = "󰖪";
    vpn = "󰒃";
    vpnOffline = "󰦝";
    wifi = "󰖩";
  };
  uiPalette = flake.inputs.nix-colors.colorSchemes.default-dark.palette;
  uiTheme = {
    bg = uiPalette.base00;
    bgAlt = uiPalette.base01;
    fg = uiPalette.base05;
    fgStrong = uiPalette.base07;
    muted = uiPalette.base03;
    blue = uiPalette.base0D;
    amber = uiPalette.base09;
    yellow = uiPalette.base0A;
    purple = uiPalette.base0E;
    green = uiPalette.base0B;
    red = uiPalette.base08;
  };
in {
  options = with lib; {
    profiles.macbookpro2025 = {
      enable = mkEnableOption ''
        Whether to enable my laptop configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Expected disk layout (matches desktop2022 style impermanence):
    # - /dev/disk/by-partlabel "EFI - NIXOS" (p6) -> /boot (vfat)
    # - /dev/disk/by-label nixos (p7)            -> /nix (ext4, persistent store/persistence root)
    profiles = {
      common.enable = true;
      workstation.enable = true;
      personalized = {
        enable = true;
        enableSoftware = true;
        webPackages = with pkgs; [
          firefox-widevine
          brave-widevine
        ];
        # enableProblematicSoftware = true;
        enableHome = true;
      };
      preferences.enable = true;
      playground.enable = true;
      niriWorkstation = {
        enable = true;
        audio = {
          raise = "${asahiAudioControl} raise";
          lower = "${asahiAudioControl} lower";
          mute = "${asahiAudioControl} mute";
          micMute = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
        renderDrmDevice = "/dev/dri/renderD128";
        idle = {
          monitorOff = 600;
          suspend = 1800;
        };
      };
    };

    networking.hostName = "macbookpro2025";

    services.printing = {
      enable = true;
      drivers = [pkgs.hplip];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    hardware.printers = {
      ensureDefaultPrinter = "HP_Envy_6055";
      ensurePrinters = [
        {
          name = "HP_Envy_6055";
          description = "HP Envy 6055";
          deviceUri = "ipp://192.168.1.7/ipp/print";
          model = "everywhere";
        }
      ];
    };

    time.timeZone = lib.mkDefault "America/New_York";
    location.provider = "geoclue2";
    services.automatic-timezoned.enable = true;

    environment.sessionVariables.MOZ_GMP_PATH =
      "${pkgs.widevine-firefox}/gmp-widevinecdm/system-installed";

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-widevine;
      preferences = {
        "widget.disable-swipe-tracker" = true;

        # Firefox's Linux default disables its built-in low-memory tab unloader.
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.low_commit_space_threshold_percent" = 15;
      };
    };

    fonts.packages = [
      pkgs.nerd-fonts.symbols-only
    ];

    # Using the systemd-boot EFI boot loader as it seems to be very simple.
    # Keep only a few generations because the EFI partition is space-constrained.
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 3;
      graceful = true;
    };

    # Make sure initrd can mount /nix early and create mount points
    boot.initrd = {
      supportedFilesystems = ["ext4" "vfat"];
      systemd.enable = true;
    };

    boot.initrd.availableKernelModules = [
      "nvme"
      "usb_storage"
      "sdhci_pci"
    ];

    fileSystems = {
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = ["size=4G" "mode=755"];
      };

      "/home/me" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "size=4G"
          "mode=777"
        ];
        neededForBoot = true;
      };

      "/nix" = {
        device = "/dev/disk/by-uuid/388b76d7-cb0d-4aef-80ee-13898a2ea81a";
        fsType = "ext4";
        neededForBoot = true;
        options = ["X-mount.mkdir"];
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/7414-141F";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077" "X-mount.mkdir"];
      };
    };

    boot.kernelModules = ["zram"];
    swapDevices = [];
    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };
    systemd.oomd.enableUserSlices = true;

    environment.automaticPersistence = {
      normal.path = "/nix/persistent";
    };

    environment.persistence."/nix/persistent" = {
      directories = [
        # Contains uuid and gid map
        "/var/lib/nixos"

        # Log files
        "/var/log"

        # Large temp that can't fit on tmpfs
        "/tmp"

        # Keep the Asahi firmware around even when using impermanence
        {
          directory = "/etc/nixos/firmware";
          mode = "0755";
        }
      ];

      users.me = lib.mkIf (config.users.users ? me) (let
        permissions = {
          user = "me";
          group = "users";
        };
      in {
        directories = [
          # Retain all of my home config for the time being
          ({directory = ".config";} // permissions)

          # Retain Claude state
          ({directory = ".claude";} // permissions)

          # Retain Codex state
          ({directory = ".codex";} // permissions)

          # Retain Pi state
          ({directory = ".pi";} // permissions)

          # Retain ssh keys for this computer
          {
            directory = ".ssh";
            mode = "0700";
          }

          # Retain my projects directory (for now)
          "projects"

          # Retain downloaded files; /home/me itself is tmpfs on this host.
          "Downloads"

          # Retain trusted nix settings and repl history (repl-history, trusted-settings.json)
          ({directory = ".local/share/nix";} // permissions)

          # Retain virtualenv wheel cache
          ({directory = ".local/share/virtualenv";} // permissions)

          # Retain neovim undo files
          ({directory = ".local/share/nvim";} // permissions)

          # Retain neovim state such as undo history
          ({directory = ".local/state/nvim";} // permissions)

          # Retain nix evaluation cache, registry cache etc
          ({directory = ".cache/nix";} // permissions)

          # Retain neovim cache
          ({directory = ".cache/nvim";} // permissions)

          # Retain Firefox cache outside tmpfs
          ({directory = ".cache/mozilla";} // permissions)

          # Retain OpenCode state
          ({directory = ".local/state/opencode";} // permissions)

          # Retain OpenCode session data
          ({directory = ".local/share/opencode";} // permissions)

          # Retain OpenCode cache
          ({directory = ".cache/opencode";} // permissions)
        ];

        files = [
          # Retain bash history
          ".bash_history"
        ];
      });
    };

    users.users.me.hashedPasswordFile = "/nix/persistent/secrets/me-password.hash";
    users.users.me.initialHashedPassword = lib.mkForce null;

    # Use the same nixpkgs/overlay as upstream apple-silicon-support so cache hits match
    hardware.asahi.enable = true;
    hardware.asahi.pkgs = lib.mkForce (import flake.inputs.apple-silicon-support.inputs.nixpkgs {
      inherit (pkgs) system;
      overlays = [flake.inputs.apple-silicon-support.overlays.apple-silicon-overlay];
    });

    # Use iwd instead of wpa_supplicant
    # See [nixos-apple-silicon recommendation](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md#nixos-installation)
    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.wifi.powersave = true;
    networking.wireless.iwd.settings.General.EnableNetworkConfiguration = true;
    systemd.services.iwd = {
      after = ["sys-subsystem-net-devices-wlan0.device"];
      wants = ["sys-subsystem-net-devices-wlan0.device"];
      serviceConfig.ExecStartPre = ["${lib.getExe' pkgs.iproute2 "ip"} link set wlan0 up"];
    };

    # Firmware extraction: expose ESP to sandboxed builds on the running system
    hardware.asahi.peripheralFirmwareDirectory = "/etc/nixos/firmware";
    nix.settings.extra-sandbox-paths = ["/etc/nixos/firmware"];

    services.logind.settings.Login.HandleLidSwitch = "suspend";
    services.tlp.enable = true;

    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "norman";
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          # capslock = "overload(control, esc)";
          capslock = "enter";
          rightshift = "overload(shift, enter)";
        };
      };
    };
    hardware.graphics.enable = true;

    # Trackpad/keyboard settings (mirror macbookpro2017 style)
    services.libinput.enable = true;
    services.libinput.touchpad.disableWhileTyping = true;

    home-manager.users.me.programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 28;
          margin = "8 14 8";
          modules-left = ["network" "custom/tailscale"];
          modules-center = ["clock"];
          modules-right = ["custom/screenshot" "custom/audio" "backlight" "battery"];

          network = {
            format-wifi = "${waybarIcons.wifi} {essid} {signalStrength}%";
            format-ethernet = waybarIcons.ethernet;
            format-linked = waybarIcons.link;
            format-disconnected = waybarIcons.networkOffline;
            tooltip-format-wifi = "Wi-Fi: {essid} ({signalStrength}%)";
            tooltip-format-ethernet = "{ifname}";
            tooltip-format-disconnected = "No network";
            on-click = "ghostty -e sh -lc 'iwctl station wlan0 scan >/dev/null 2>&1 || true; nmtui'";
          };

          "custom/tailscale" = {
            return-type = "json";
            interval = 15;
            format = "{}";
            exec = ''
              sh -lc 'if tailscale status --json >/tmp/tailscale-waybar.json 2>/dev/null; then jq -r '"'"'. as $s | if $s.BackendState == "Running" then {text:"${waybarIcons.vpn} VPN", tooltip:("VPN: " + ($s.Self.HostName // "-") + "\n" + ($s.Self.TailscaleIPs[0] // "-")), class:"connected"} else {text:"${waybarIcons.vpnOffline} VPN", tooltip:"VPN offline", class:"offline"} end | @json'"'"' /tmp/tailscale-waybar.json; else printf "{\"text\":\"${waybarIcons.vpnOffline} VPN\",\"tooltip\":\"VPN offline\",\"class\":\"offline\"}"; fi'
            '';
          };

          "custom/screenshot" = {
            format = waybarIcons.screenshot;
            tooltip = true;
            tooltip-format = "Screenshot and annotate (Mod+Shift+S)";
            on-click = "screenshot-and-annotate";
          };

          clock = {
            format = "{:%a %d %b  %H:%M}";
            tooltip-format = "{:%Y-%m-%d}";
          };

          "custom/audio" = {
            return-type = "json";
            interval = 5;
            signal = 8;
            format = "{}";
            exec = "${asahiAudioControl} status '${waybarIcons.audio}' '${waybarIcons.audioMuted}'";
            on-click = "${asahiAudioControl} mute";
            on-scroll-up = "${asahiAudioControl} raise-small";
            on-scroll-down = "${asahiAudioControl} lower-small";
          };

          backlight = {
            device = "apple-panel-bl";
            format = "${waybarIcons.backlight} {percent}%";
            on-scroll-up = "${lib.getExe pkgs.brightnessctl} set +5%";
            on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 5%-";
          };

          battery = {
            format = "${waybarIcons.battery} {capacity}% {power}W";
            format-charging = "${waybarIcons.batteryCharging} {capacity}% {power}W";
            format-plugged = "${waybarIcons.batteryPlugged} {capacity}% AC";
            tooltip-format = "Battery: {capacity}%\n{power}W\n{time}";
          };
        }
      ];
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: monospace, "Symbols Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
          color: #${uiTheme.fg};
        }

        #network,
        #custom-tailscale,
        #custom-screenshot,
        #clock,
        #custom-audio,
        #backlight,
        #battery {
          padding: 0 11px;
          margin: 2px 5px;
          border-radius: 999px;
          background: #${uiTheme.bgAlt};
        }

        #network {
          color: #${uiTheme.blue};
        }

        #custom-screenshot {
          color: #${uiTheme.fg};
        }

        #custom-audio {
          color: #${uiTheme.purple};
        }

        #custom-audio.muted {
          color: #${uiTheme.muted};
        }

        #backlight {
          color: #${uiTheme.amber};
        }

        #battery.charging {
          color: #${uiTheme.green};
        }

        #custom-tailscale.connected {
          color: #${uiTheme.blue};
        }

        #custom-tailscale.offline {
          color: #${uiTheme.muted};
        }

        #battery.warning:not(.charging) {
          color: #${uiTheme.amber};
        }

        #battery.critical:not(.charging) {
          color: #${uiTheme.red};
        }
      '';
    };
    # GUI for asking for ssh password on non-headless laptop sessions
    programs.ssh.enableAskPassword = true;
    programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    environment.variables.SUDO_ASKPASS = config.programs.ssh.askPassword;

    # Cloud password manager
    programs._1password-gui.enable = true;

    # Pin state version explicitly
    system.stateVersion = "25.11";
    home-manager.users.me.home.stateVersion = "25.11";
  };
}
