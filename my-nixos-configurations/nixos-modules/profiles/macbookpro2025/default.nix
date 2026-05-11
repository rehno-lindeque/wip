{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.macbookpro2025;
  waybarIcons = {
    audio = "";
    audioMuted = "󰝟";
    backlight = "󰃠";
    battery = "󰁹";
    batteryCharging = "󰂄";
    batteryPlugged = "󰚥";
    ethernet = "󰈀";
    link = "󰈁";
    networkOffline = "󰖪";
    vpn = "󰒃";
    vpnOffline = "󰦝";
    wifi = "󰖩";
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
    };

    networking.hostName = "macbookpro2025";

    environment.sessionVariables.MOZ_GMP_PATH =
      "${pkgs.widevine-firefox}/gmp-widevinecdm/system-installed";

    fonts.packages = [
      pkgs.nerd-fonts.symbols-only
    ];

    programs.light.enable = true;

    # Using the systemd-boot EFI boot loader as it seems to be very simple
    boot.loader.systemd-boot.enable = true;

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

    swapDevices = [];

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

          # Retain ssh keys for this computer
          {
            directory = ".ssh";
            mode = "0700";
          }

          # Retain my projects directory (for now)
          "projects"

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

    # Start with a minimal native niri session
    programs.niri = {
      enable = true;
      useNautilus = false;
    };
    systemd.user.services.niri.enableDefaultPath = false;
    services.greetd.enable = true;
    services.greetd.settings.default_session = {
      command = "${lib.getExe pkgs.tuigreet} --time --cmd niri-session";
      user = "greeter";
    };
    services.gnome.gcr-ssh-agent.enable = false;
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
        };
      };
    };
    hardware.graphics.enable = true;

    # Trackpad/keyboard settings (mirror macbookpro2017 style)
    services.libinput.enable = true;
    services.libinput.touchpad.disableWhileTyping = true;

    home-manager.users.me.home.packages = with pkgs; [
      fuzzel
      wl-clipboard
      flake.packages.${pkgs.system}.desktop2022-project-session
      flake.packages.${pkgs.system}.session-picker
    ];
    home-manager.users.me.home.file."projects/screenshots/.keep".text = "";
    home-manager.users.me.programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 28;
          modules-left = ["network" "custom/tailscale"];
          modules-center = ["clock"];
          modules-right = ["pulseaudio" "backlight" "battery"];

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

          clock = {
            format = "{:%a %d %b  %H:%M}";
            tooltip-format = "{:%Y-%m-%d}";
          };

          pulseaudio = {
            format = "${waybarIcons.audio} {volume}%";
            format-muted = waybarIcons.audioMuted;
            tooltip-format = "Audio: {desc}";
            on-click = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-scroll-up = "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
            on-scroll-down = "${lib.getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
          };

          backlight = {
            device = "apple-panel-bl";
            format = "${waybarIcons.backlight} {percent}%";
            on-scroll-up = "${lib.getExe pkgs.light} -A 5";
            on-scroll-down = "${lib.getExe pkgs.light} -U 5";
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
          background: rgba(14, 16, 20, 0.86);
          color: #e6e6e6;
        }

        #network,
        #custom-tailscale,
        #clock,
        #pulseaudio,
        #backlight,
        #battery {
          padding: 0 11px;
          margin: 4px 6px;
          border-radius: 8px;
          background: rgba(255, 255, 255, 0.06);
        }

        #network {
          color: #a7d8ff;
        }

        #pulseaudio {
          color: #d7c1ff;
        }

        #pulseaudio.muted {
          color: #888888;
        }

        #backlight {
          color: #ffe0a3;
        }

        #battery.charging {
          color: #b8e986;
        }

        #custom-tailscale.connected {
          color: #9fd7ff;
        }

        #custom-tailscale.offline {
          color: #888888;
        }

        #battery.warning:not(.charging) {
          color: #ffd27f;
        }

        #battery.critical:not(.charging) {
          color: #ff8a7a;
        }
      '';
    };
    home-manager.users.me.services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
        }
        {
          timeout = 1800;
          command = "systemctl suspend";
        }
      ];
    };
    home-manager.users.me.xdg.configFile."niri/config.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "us"
                  variant "norman"
              }
          }

          touchpad {
              dwt
          }
      }

      layout {
          gaps 16

          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }

          default-column-width { proportion 0.5; }

          focus-ring {
              width 4
              active-color "#7fc8ff"
              inactive-color "#505050"
          }

          border {
              off

              width 4
              active-color "#ffc87f"
              inactive-color "#505050"
              urgent-color "#9b0000"
          }

          shadow {
              off
          }
      }

      spawn-at-startup "waybar"

      hotkey-overlay {
      }

      debug {
          render-drm-device "/dev/dri/renderD128"
      }

      prefer-no-csd

      screenshot-path "~/projects/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      animations {
          off
      }

      window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
      }

      binds {
          Mod+Shift+Slash { show-hotkey-overlay; }
          Mod+Shift+Return hotkey-overlay-title="Open desktop2022 project session" { spawn "desktop2022-project-session"; }
          Mod+Shift+Space hotkey-overlay-title="Pick a detached session" { spawn "session-picker"; }

          Mod+B hotkey-overlay-title="Open a Browser: firefox" { spawn "firefox"; }
          Mod+Return hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
          Mod+Space hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
          XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

          XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
          XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
          XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
          XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

          XF86MonBrightnessUp allow-when-locked=true { spawn "${lib.getExe pkgs.light}" "-A" "10"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "${lib.getExe pkgs.light}" "-U" "10"; }

          Mod+Tab repeat=false { toggle-overview; }
          Mod+Q repeat=false { close-window; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+Y     { focus-column-left; }
          Mod+N     { focus-window-down; }
          Mod+I     { focus-window-up; }
          Mod+O     { focus-column-right; }

          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+Y     { move-column-left; }
          Mod+Ctrl+N     { move-window-down; }
          Mod+Ctrl+I     { move-window-up; }
          Mod+Ctrl+O     { move-column-right; }

          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }

          Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

          Mod+WheelScrollRight      { focus-column-right; }
          Mod+WheelScrollLeft       { focus-column-left; }
          Mod+Ctrl+WheelScrollRight { move-column-right; }
          Mod+Ctrl+WheelScrollLeft  { move-column-left; }

          Mod+Shift+WheelScrollDown      { focus-column-right; }
          Mod+Shift+WheelScrollUp        { focus-column-left; }
          Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
          Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+Comma  { consume-window-into-column; }
          Mod+Period { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-column-width-back; }
          Mod+Ctrl+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }

          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+M { maximize-window-to-edges; }
          Mod+Ctrl+F { expand-column-to-available-width; }
          Mod+C { center-column; }
          Mod+Ctrl+C { center-visible-columns; }

          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }
          Mod+W { toggle-column-tabbed-display; }

          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
          Ctrl+Alt+Delete { quit; }
      }
    '';

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
