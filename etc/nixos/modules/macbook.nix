{ pkgs, lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options = {
    macbook = {
      hardware = {
        sdCardReader = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Disabling the internal cardreader may save battery life. Set this to false to turn it off.
            '';
          };
        };
      };
    };
  };
}
