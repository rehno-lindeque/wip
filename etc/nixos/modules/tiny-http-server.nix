{ pkgs
, lib
, config
, ...
}:

let
  inherit (lib) mkOption types;
  cfg = config.services.tiny-http-server;
  inherit (lib) mkIf;
in
{
  options = {
    services.tiny-http-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the tiny-http-server. A minimal HTTP service for debugging purposes only.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.tiny-http-server = {
      description = "Tiny HTTP server for debugging purposes";
      wantedBy = [ "multi-user.tagret" ];
      after = [ "network.target" ];
      script =
        let
          run-tiny-http-server = pkgs.writeScript "run-tiny-http-server" ''
            while true; do
              echo -e "HTTP/1.1 200 OK\n\n $(date)" | ${pkgs.netcat}/bin/nc -l 80;
              sleep 1;
            done'';
        in ''
          echo "starting....... TINY"
          echo ".................."
          echo ".................."
          echo ".................."
          echo ".................."
          echo ".................."
          ${run-tiny-http-server}
          '';
    };
  };
}
