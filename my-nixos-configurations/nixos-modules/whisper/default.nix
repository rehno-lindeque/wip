{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.services.whisper;
in {
  options = with lib; {
    services.whisper = {
      # See also https://github.com/kylecarbs/whispertype
      enable = mkEnableOption "Whisper speech transcription service";

      user = mkOption {
        type = types.str;
        default = "whisper";
      };

      group = mkOption {
        type = types.str;
        default = "whisper";
      };

      port = mkOption {
        type = types.int;
        description = "Port to bind whisper-cpp-server";
        default = 8080;
      };

      host = mkOption {
        type = types.str;
        description = "Host to bind whisper-cpp-server";
        default = "localhost";
      };

      package = mkOption {
        type = types.package;
        description = "The whisper.cpp package to use";
        default = pkgs.openai-whisper-cpp;
      };

      inferencePath = mkOption {
        type = types.str;
        description = "Inference path for all requests";
        default = "/inference";
      };

      model = mkOption {
        type = types.path;
        description = "The whisper.cpp model to use";
        default = flake.inputs.whisper-model;
      };

      prompt = mkOption {
        type = types.str;
        description = "Transcription prompt, see https://cookbook.openai.com/examples/whisper_prompting_guide";
        default = "";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.whisper-cpp-server = {
        description = "Whisper Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.ffmpeg ];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart = ''
            ${cfg.package}/bin/whisper-cpp-server \
              --model ${cfg.model} \
              --prompt '${cfg.prompt}' \
              --host ${cfg.host} \
              --port ${toString cfg.port} \
              --inference-path ${toString cfg.inferencePath} \
              --convert
          '';
          Restart = "always";
          RestartSec = "10";
          Type = "simple";
        };
      };
    })

    (lib.mkIf (cfg.enable && (cfg.group == "whisper")) {
      users.groups.whisper = {};
    })

    (lib.mkIf (cfg.enable && (cfg.user == "whisper")) {
      users.users.whisper = {
        group = cfg.group;
        isSystemUser = true;
      };
    })
  ];
}
