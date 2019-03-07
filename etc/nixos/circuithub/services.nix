{ pkgs
, config
, ...
}:

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

  };
}
