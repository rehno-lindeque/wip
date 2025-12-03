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
        description = "Port to bind whisper-server";
        default = 8080;
      };

      host = mkOption {
        type = types.str;
        description = "Host to bind whisper-server";
        default = "localhost";
      };

      package = mkOption {
        type = types.package;
        description = "The whisper.cpp package to use";
        default = pkgs.whisper-cpp;
      };

      inferencePath = mkOption {
        type = types.str;
        description = "Inference path for all requests";
        default = "/inference";
      };

      model = mkOption {
        type = types.path;
        description = "The whisper.cpp model to use";
        default = pkgs.fetchurl {
          url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/5359861c739e955e79d9a303bcbc70fb988958b1/ggml-base.en.bin";
          sha256 = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
        };
      };

      prompt = mkOption {
        type = types.str;
        description = "Transcription prompt, see https://cookbook.openai.com/examples/whisper_prompting_guide";
        default = "";
      };

      convert = mkOption {
        type = types.bool;
        description = "Use ffmpeg to convert file formats automatically";
        default = false;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      systemd.services.whisper-server = {
        description = "Whisper Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = lib.optional cfg.convert pkgs.ffmpeg;

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStart =
            lib.concatStringsSep "\\\n  " ([
              # "${cfg.package}/bin/whisper-server"
              "${cfg.package}/bin/whisper-cpp-server"
              "--model ${cfg.model}"
              "--prompt '${cfg.prompt}'"
              "--host ${cfg.host}"
              "--port ${toString cfg.port}"
              "--inference-path ${toString cfg.inferencePath}"
            ] ++ lib.optional cfg.convert "--convert");
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
