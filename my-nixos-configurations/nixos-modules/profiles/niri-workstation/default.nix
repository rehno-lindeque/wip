{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.niriWorkstation;
  screenshotAndAnnotate = pkgs.writeShellScriptBin "screenshot-and-annotate" ''
    ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.satty} -f -
  '';
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
    red = uiPalette.base08;
  };
  mkFuzzelConfig = {
    accent,
    width,
    lines,
  }: ''
    font=monospace:size=13,Symbols Nerd Font:size=13
    width=${toString width}
    lines=${toString lines}
    horizontal-pad=24
    vertical-pad=10
    inner-pad=8

    [colors]
    background=${uiTheme.bg}ee
    text=${uiTheme.fg}ff
    prompt=${accent}ff
    placeholder=${uiTheme.muted}ff
    input=${uiTheme.fgStrong}ff
    match=${accent}ff
    selection=${uiTheme.bgAlt}ff
    selection-text=${uiTheme.fgStrong}ff
    selection-match=${accent}ff
    counter=${uiTheme.muted}ff
    border=${accent}ff

    [border]
    width=2
    radius=10
    selection-radius=8
  '';
  wallpaper = pkgs.fetchurl {
    url = "https://cdna.artstation.com/p/assets/images/images/098/161/548/4k/harish-rajan-train-03.webp?1776282613";
    hash = "sha256-RI/KERuKYPLcIpjawRsElocoOtEcZy6UR/D4dqoLqSg=";
  };
  optionalTimeout = timeout: command:
    lib.optional (timeout != null) {
      inherit timeout command;
    };
in {
  options.profiles.niriWorkstation = {
    enable = lib.mkEnableOption "the shared niri workstation environment";

    audio = {
      raise = lib.mkOption {type = lib.types.str;};
      lower = lib.mkOption {type = lib.types.str;};
      mute = lib.mkOption {type = lib.types.str;};
      micMute = lib.mkOption {type = lib.types.str;};
    };

    renderDrmDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    idle = {
      lock = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
      };
      monitorOff = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
      };
      suspend = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      useNautilus = false;
    };
    xdg.portal.config.niri = {
      default = ["gnome" "gtk"];
      "org.freedesktop.impl.portal.Access" = "gtk";
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
      "org.freedesktop.impl.portal.Notification" = "gtk";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    };
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${lib.getExe pkgs.tuigreet} --time --cmd niri-session";
        user = "greeter";
      };
    };
    services.gnome.gcr-ssh-agent.enable = false;

    home-manager.users.me = {
      home.packages = with pkgs; [
        fuzzel
        grim
        satty
        screenshotAndAnnotate
        slurp
        swaybg
        wl-clipboard
        xwayland-satellite
        flake.packages.${pkgs.system}.desktop2022-project-session
        flake.packages.${pkgs.system}.session-picker
      ];
      home.file."projects/screenshots/.keep".text = "";

      programs.swaylock.enable = true;
      programs.waybar.enable = true;
      services.swayidle = {
        enable = true;
        timeouts = lib.mkForce (
          optionalTimeout cfg.idle.lock "${lib.getExe pkgs.swaylock} --daemonize"
          ++ optionalTimeout cfg.idle.monitorOff "${lib.getExe config.programs.niri.package} msg action power-off-monitors"
          ++ optionalTimeout cfg.idle.suspend "${lib.getExe' pkgs.systemd "systemctl"} suspend"
        );
      };

      xdg.configFile = {
        "fuzzel/fuzzel.ini".text = mkFuzzelConfig {
          accent = uiTheme.blue;
          width = 52;
          lines = 15;
        };
        "fuzzel/session-picker.ini".text = mkFuzzelConfig {
          accent = uiTheme.yellow;
          width = 76;
          lines = 20;
        };
        "fuzzel/desktop2022-project-session.ini".text = mkFuzzelConfig {
          accent = uiTheme.amber;
          width = 64;
          lines = 16;
        };
        "niri/config.kdl".text = ''
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
              gaps 14

              struts {
                  top -14
              }

              preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
              }

              default-column-width { proportion 0.5; }

              focus-ring {
                  width 4
                  active-color "#${uiTheme.blue}"
                  inactive-color "#${uiTheme.muted}"
              }

              border {
                  off

                  width 4
                  active-color "#${uiTheme.amber}"
                  inactive-color "#${uiTheme.muted}"
                  urgent-color "#${uiTheme.red}"
              }

              shadow {
                  off
              }
          }

          spawn-at-startup "${lib.getExe pkgs.swaybg}" "--image" "${wallpaper}" "--mode" "fill"
          spawn-at-startup "${lib.getExe pkgs.waybar}"

          hotkey-overlay {
          }

          ${lib.optionalString (cfg.renderDrmDevice != null) ''
            debug {
                render-drm-device "${cfg.renderDrmDevice}"
            }
          ''}

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

              XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "${cfg.audio.raise}"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn-sh "${cfg.audio.lower}"; }
              XF86AudioMute allow-when-locked=true { spawn-sh "${cfg.audio.mute}"; }
              XF86AudioMicMute allow-when-locked=true { spawn-sh "${cfg.audio.micMute}"; }

              XF86AudioPlay allow-when-locked=true { spawn "${lib.getExe pkgs.playerctl}" "play-pause"; }
              XF86AudioStop allow-when-locked=true { spawn "${lib.getExe pkgs.playerctl}" "stop"; }
              XF86AudioPrev allow-when-locked=true { spawn "${lib.getExe pkgs.playerctl}" "previous"; }
              XF86AudioNext allow-when-locked=true { spawn "${lib.getExe pkgs.playerctl}" "next"; }

              XF86MonBrightnessUp allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "+10%"; }
              XF86MonBrightnessDown allow-when-locked=true { spawn "${lib.getExe pkgs.brightnessctl}" "set" "10%-"; }

              Mod+Tab repeat=false { toggle-overview; }
              Mod+Q repeat=false { close-window; }

              Mod+Left  { focus-column-left; }
              Mod+Down  { focus-workspace-down; }
              Mod+Up    { focus-workspace-up; }
              Mod+Right { focus-column-right; }
              Mod+Y     { focus-column-left; }
              Mod+N     { focus-workspace-down; }
              Mod+I     { focus-workspace-up; }
              Mod+O     { focus-column-right; }

              Mod+Ctrl+Left  { move-column-left; }
              Mod+Ctrl+Down  { move-column-to-workspace-down; }
              Mod+Ctrl+Up    { move-column-to-workspace-up; }
              Mod+Ctrl+Right { move-column-right; }
              Mod+Ctrl+Y     { move-column-left; }
              Mod+Ctrl+N     { move-column-to-workspace-down; }
              Mod+Ctrl+I     { move-column-to-workspace-up; }
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
              Mod+Shift+Down      { move-workspace-down; }
              Mod+Shift+Up        { move-workspace-up; }
              Mod+Shift+N         { move-workspace-down; }
              Mod+Shift+I         { move-workspace-up; }

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

              Mod+Shift+S hotkey-overlay-title="Screenshot and Annotate" { spawn "${lib.getExe screenshotAndAnnotate}"; }

              Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
              Ctrl+Alt+Delete { quit; }
          }
        '';
      };
    };
  };
}
