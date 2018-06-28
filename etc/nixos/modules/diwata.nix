{ pkgs, config, lib, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.services.ipfs;
  inherit (lib) mkIf;
  inherit (pkgs) runCommand;

  databaseOpts = { user, ... }:
    { options = {
        host = mkOption {
          type = types.str;
          description = ''
            Hostname (or IP address) of the database.
          '';
          example = "localhost";
        };
        dbname = mkOption {
          type = types.str;
          description = ''
            Database name.
          '';
        };
        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The database user to connect with.
            '';
        };
        port = mkOption {
          type = types.int;
          default = 5432;
          description = ''
            The database port to connect with.
          '';
          example = 5432;
        };
      };
    };

in
{
  options = {
    services.diwata = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the diwata service
        '';
      };

      user = mkOption {
        type = types.str;
        default = "diwata";
        description = ''
          User account under which diwata runs.  A diwata account
          is created by default if none is specified.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "diwata";
        description = ''
          Group under which diwata runs.  A diwata group is
          automatically created if it doesn't exist.
        '';
      };

      database = mkOption {
        type = types.nullOr (types.submodule databaseOpts);
        description = ''
          The database to connect with.
        '';
        default = null;
        example = {
          host = "localhost";
          dbname = "somedb";
          user = "someuser";
          port = 5432;
        };
      };

    };
  };
  config = mkIf cfg.enable {
  };
}
