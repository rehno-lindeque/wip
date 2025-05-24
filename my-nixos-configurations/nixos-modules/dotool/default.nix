{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.dotool;
in {
  # See also https://github.com/postsolar/config/blob/913ad6d5c5b515e16827ed2a563af566534790f5/modules/nixos/dotool.nix
  # and https://git.sr.ht/~geb/

  options = with lib; {
    services.dotool = {
      enable = mkEnableOption " speech transcription service";

      user = mkOption {
        type = types.str;
        default = "dotool";
      };

      group = mkOption {
        type = types.str;
        default = "dotool";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.sessionVariables = {
        DOTOOL_PIPE = "/run/dotoold/pipe";
      };

      hardware.uinput.enable = lib.mkDefault true;

      systemd.services.dotool = {
        description = "Dotool Daemon";
        wantedBy = [ "multi-user.target" ];
        partOf = [ "multi-user.target" ];

        environment = {
          DOTOOL_PIPE = "/run/dotoold/pipe";
          # DOTOOL_XKB_LAYOUT = "en"
        };

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          SupplementaryGroups = [
            config.users.groups.uinput.name
          ];
          ExecStart = "${pkgs.dotool}/bin/dotoold";
          Restart = "always";
          RestartSec = 10;
          RuntimeDirectory = "dotoold";

          # Hardening
          # TODO use systemd-analyze security
          # See also:
          # * https://github.com/NixOS/nixpkgs/blob/df4e885a2cbc70e5c4102c87623a2696a143c924/nixos/modules/services/hardware/keyd.nix#L154
          # * https://github.com/NixOS/nixpkgs/blob/bea66f47b26db5e033510da9546bc19629c1dd0c/nixos/modules/programs/ydotool.nix#L46-L84
          DeviceAllow = [ "/dev/uinput" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && (cfg.group == "dotool")) {
      users.groups.dotool = {};
    })

    (lib.mkIf (cfg.enable && (cfg.user == "dotool")) {
      users.users.dotool = {
        group = cfg.group;
        isSystemUser = true;
      };
    })
  ];
}
