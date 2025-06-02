{
  flake,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.llm;

  # inherit (pkgs.localSystem) system;
  inherit (pkgs) system;

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
        pkgs.writeShellApplication {
          name = "llm-${name}";
          runtimeInputs = [
            cfg.package
            pkgs.socat
            flake.inputs.clump.packages.${system}.clump
          ];
          text = ''
            ${lib.optionalString
              (spec.relay != null)
              "exec socat -u ${spec.relay} - |"}
            tee /dev/stderr |
            clump --interval 3s --prefix '!multiline\n' --suffix '\n!end\n' |
            llm chat --system ${lib.escapeShellArg spec.instructions} "$@"
          '';
        };
    in
      [
        cfg.package
      ]
      ++ lib.mapAttrsToList mkLauncher cfg.agents;
  };
}
