{ pkgs, config, lib, ... }:
# let
#   ipfs-expr = pkgs.fetchurl {
#       url = "https://raw.githubusercontent.com/elitak/nixpkgs/5050c5638235ee2af92dfc769ea0476bc049e62d/nixos/modules/services/network-filesystems/ipfs.nix";
#       sha256 = "17r88rdiilhf956nh0d45bgk1q7614vnbx1057kw96x308f22ris";
#     };
# in
  # ipfs-expr.outPath
  # pkgs.callPackage ipfs-expr.outPath {}

let
  cfg = config.services.ipfs;
  inherit (lib) mkIf;
  inherit (pkgs) runCommand;
in
{
  config = mkIf cfg.enable {
    systemd.globalEnvironment = {
      # For additional safety, ensure that we're always using a private network with ipfs
      # See https://github.com/ipfs/go-ipfs/blob/master/docs/experimental-features.md#how-to-enable-5
      LIBP2P_FORCE_PNET = "1";
    };
    
    # systemd.services.ipfs.path =
    #   let
    #     # text = builtins.readFile ../asdfsafd.key;
    #     text = "";
    #     executable = false;
    #     swarmKey =
    #       runCommand "swarmKey"
    #         { inherit text;
    #           passAsFile = [ "text" ];
    #           preferLocalBuild = true;
    #           allowSubstitutes = false;
    #         }
    #         ( let
    #             destination = builtins.toPath (cfg.dataDir + "/swarm.key");
    #             # destination = "/var/lib/ipfs/.ipfs/swarm.key"
    #           in ''
    #             n=$out${destination}
    #             mkdir -p "$(dirname "$n")"
    #             echo -n "$text" > "$n"
    #             # chown -R '${cfg.user}:${cfg.group}' "$n"
    #             ''
    #         );
    #   in
    #     # systemd.services.ipfs.path ++ [ swarmKey ];
    #     [ swarmKey ];
    # systemd.services.ipfs.script = ''
    #   export LIBP2P_FORCE_PNET=1
    # '';
  };
}
