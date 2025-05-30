{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.llm;

  agent = with lib;
    types.submodule {
      options = {
        instructions = mkOption {
          type = types.str;
          description = "System prompt passed to llm for this role.";
        };

        relay = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "socat address for chat input";
          example = "UNIX-CONNECT:/run/mymux/<name>.sock";
        };
      };
    };
in {
  options = with lib; {
    programs.llm = {
      enable = mkEnableOption "Enable the llm terminal application along with launchers for each agent.";

      package = mkOption {
        type = types.package;
        default = pkgs.llm;
        description = "Package that provides the `llm` binary.";
      };

      agents = mkOption {
        type = types.attrsOf agent;
        default = {};
        description = ''
          Enable llm-<agentname> launchers for each llm agent.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = let
      mkLauncher = name: spec:
        pkgs.writeShellScriptBin "llm-${name}" (
          lib.optionalString (spec.relay != null) ''exec ${pkgs.socat}/bin/socat -u ${spec.relay} - |''
          + ''${cfg.package}/bin/llm chat --system ${lib.escapeShellArg spec.instructions} "$@"''
        );
    in
      [
        cfg.package
      ]
      ++ lib.mapAttrsToList mkLauncher cfg.agents;
  };
}
