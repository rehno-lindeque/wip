{ pkgs
, ... 
}:

{
  services = {
    mysql = {
      enable = true;
      package = pkgs.mysql;
      # port = ;
      # user = "";
      # initialDatabases = [{ name = "____________"; schema = ./____________.sql; } { name = "____________"; schema = ./____________.sql; }];
    };
    rabbitmq.enable = true;
    redis.enable = true;
    # dropbox.enable = true;
  };
}
