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
        thunderboltPre2015 = {
          # See https://github.com/Dunedan/mbp-2016-linux/issues/24#issuecomment-311006923
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Ostensibly this only works on macbooks older that 2015.
              If you don't use 
              permanently because Apple didn't bother to support Thunderbolt 
            '';
          };
        };
      };
    };
  };
}
