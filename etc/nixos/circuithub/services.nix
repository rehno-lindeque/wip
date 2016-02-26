{ pkgs
, ... 
}:

{
  services = {
    # Passwords, users not stored here - use
    # CREATE USER 'someone'@'localhost' IDENTIFIED BY 'mypass';
    # GRANT ALL ON db.* TO someone@localhost;
    # GRANT ALL ON db-test.* TO someone@localhost;

    mysql = {
      enable = true;
      package = pkgs.mysql;
      port = # mysql port ; #gitignore
      user = # mysql user ; #gitignore
      initialDatabases =
        [
          { name = # db #gitignore
            schema = # initialization sql #gitignore
          }
          { name = # db #gitignore
            schema = # initialization sql #gitignore
          }
        ];
    };
    rabbitmq.enable = true;
    redis.enable = true;
    # dropbox.enable = true;
  };
}
