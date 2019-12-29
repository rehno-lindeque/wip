{ pkgs
, config
, lib
, ...
}:

let
  udevMouseProxy = false; # Turn on to deploy mouse proxy
in
lib.recursiveUpdate
{
  # #
  # # Redirect localhost routes to circuithub.test subdomains
  # # This lets you work with the Elm Reactor while making AJAX calls to localhost (while avoiding CORS problems).
  # #
  # networking.extraHosts =
  #   ''
  #     127.0.0.1 circuithub.test
  #     127.0.0.1 projects.circuithub.test
  #     127.0.0.1 api.circuithub.test
  #     127.0.0.1 reactor.circuithub.test
  #   '';
  # services.nginx =
  #     {
  #       enable = true;
  #       httpConfig =
  #       ''
  #           ## Start client.lanlocal.x ##
  #           server {
  #             listen       80;
  #             server_name  circuithub.test;
  #             ## send request back to apache1 ##
  #             location / {
  #               proxy_pass  http://127.0.0.1:8081;
  #               proxy_set_header Host $host;
  #               proxy_set_header X-Real-IP $remote_addr;
  #               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #               proxy_set_header X-Forwarded-Proto $scheme;
  #             }
  #           }
  #           ## Start api.lanlocal.x ##
  #           server {
  #             listen       80;
  #             server_name  api.circuithub.test;
  #             ## send request back to apache1 ##
  #             location / {
  #               proxy_pass  http://127.0.0.1:8082;
  #               proxy_set_header Host $host;
  #               proxy_set_header X-Real-IP $remote_addr;
  #               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #               proxy_set_header X-Forwarded-Proto $scheme;
  #             }
  #           }
  #           ## Start projects.lanlocal.x ##
  #           server {
  #             listen       80;
  #             server_name  projects.circuithub.test;
  #             ## send request back to apache1 ##
  #             location / {
  #               proxy_pass  http://127.0.0.1:8083;
  #               proxy_set_header Host $host;
  #               proxy_set_header X-Real-IP $remote_addr;
  #               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #               proxy_set_header X-Forwarded-Proto $scheme;
  #             }
  #           }
  #           ## Start reactor.lanlocal.x ##
  #           server {
  #             listen       80;
  #             server_name  reactor.circuithub.test;
  #             ## send request back to apache1 ##
  #             location / {
  #               proxy_pass  http://localhost:8000;
  #               proxy_set_header Host $host;
  #               proxy_set_header X-Real-IP $remote_addr;
  #               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #               proxy_set_header X-Forwarded-Proto $scheme;
  #             }
  #           }
  #       '';
  #     };


  services = {

    # Note that rabbitmq adds 2 seconds to systemd startup
    #
    # $ systemd-analyze blame | grep rabbitmq
    # 2.010s rabbitmq.service
    #
    /* rabbitmq.enable = true; */

    redis.enable = true;
    journald.rateLimitBurst = 1000;
    postgresql =
      {
        # enable = true;
        package = pkgs.postgresql95;
        initialScript = pkgs.writeText "postgresql-init.sql" '' CREATE ROLE ${config.users.users.me.name} WITH superuser login createdb; '';
        authentication = pkgs.lib.mkForce
          ''
          local   all             all                                     trust
          host    all             all             127.0.0.1/32            trust
          host    all             all             ::1/128                 trust
          '';
        extraConfig =
          ''
            log_min_duration_statement = 0
            track_activity_query_size=16384
          '';
      };

    # Virtual Private Network
    /* strongswan.enable = true; */

    /*
    nginx =
      { enable =
          true;

        virtualHosts =
          { "localhost" =
            {
              # enableACME = true;
              # forceSSL = true;
              locations."/" = { proxyPass = "https://www.....com/"; };
              extraConfig = ''
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'X-Frame-Options' 'allow-from *';
                '';
                # add_header 'Content-Security-Policy' 'frame-ancestors * filesystem:';
                # add_header 'X-Frame-Options' 'allow-from *';
                # add_header 'Access-Control-Allow-Origin' '*';
                # add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                # add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
                # add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
                # add_header X-Frame-Options "";
                # proxy_hide_header X-Frame-Options
              # extraConfig = ''
              #   add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
              #   add_header X-Content-Type-Options nosniff;
              #   add_header X-XSS-Protection "1; mode=block";
              #   add_header X-Frame-Options DENY;
              # '';
            };
          };

         # "${cfg.hostname}" = {
         #   forceSSL = true;
         #   enableACME = true;
         #   locations."/" = { proxyPass = "http://127.0.0.1:5232"; };
         #   extraConfig = ''
         #     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
         #     add_header X-Content-Type-Options nosniff;
         #     add_header X-XSS-Protection "1; mode=block";
         #     add_header X-Frame-Options DENY;
         #   '';
         # };
      };
      */


  };

}
(if ! udevMouseProxy then {} else
{
  boot.kernelModules = [ "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0666"
    KERNEL=="event*", MODE="0666"
  '';
})
