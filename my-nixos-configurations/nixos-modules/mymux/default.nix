{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mymux;
in
{
  options = {
    services.mymux = with lib; {
      enable = mkEnableOption "My personal mulitplex conversation router";
      addresses = {
        output = mkOption {
          type = types.str;
          default = "UNIX-LISTEN:/run/mymux/out.sock,fork,mode=0666";
          description = "socat address specification for output";
        };
        code = mkOption {
          type = types.str;
          default = "UNIX-LISTEN:/run/mymux/code.sock,fork,mode=0666";
          description = "socat address specification for code snippets";
        };
        transcript = mkOption {
          type = types.str;
          default = "UNIX-LISTEN:/run/mymux/transcript.sock,fork,mode=0666";
          description = "socat address specification for voice transcription input";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.mymux = {
      description = "My personal multiplex conversation router";

      # To test this service run these in different terminals
      # socat - UNIX-CONNECT:/run/mymux/code.sock
      # socat - UNIX-CONNECT:/run/mymux/transcript.sock
      # socat - UNIX-CONNECT:/run/mymux/out.sock

      path = [
        pkgs.socat
      ];
      script = ''
        # Forward code and transcript to the FIFO
        socat -u ${cfg.addresses.code},ignoreeof PIPE:/run/mymux/broadcast,unlink-close=0 &
        socat -u ${cfg.addresses.transcript},ignoreeof PIPE:/run/mymux/broadcast,unlink-close=0 &

        # Broadcast FIFO contents to every connecting client
        socat -u PIPE:/run/mymux/broadcast,ignoreeof,nonblock=1,rdonly=1,unlink-close=0 ${cfg.addresses.output}
      '';

      serviceConfig = {
        RuntimeDirectory = "mymux";
        RuntimeDirectoryMode = "0755";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}
