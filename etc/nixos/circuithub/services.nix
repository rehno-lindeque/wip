{ pkgs
, config
, ...
}:

{
  services = {
    # Development

    # Note that rabbitmq adds 2 seconds to systemd startup
    #
    # $ systemd-analyze blame | grep rabbitmq
    # 2.010s rabbitmq.service
    #
    /* rabbitmq.enable = true; */
                            
    redis.enable = true;
    journald.rateLimitBurst = 1000;
    postgresql = {
      enable = true;
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

