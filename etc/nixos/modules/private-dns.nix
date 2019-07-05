{ pkgs, lib, config, ... }:


# Use Tor or TLS with stubby and cloudflare's 1.1.1.1 for increased privacy in domain name resolution.
# https://blog.cloudflare.com/welcome-hidden-resolver/
# https://github.com/Chiiruno/configuration/commit/114807da725e62a109ef1dea6826cb8d48b04476
# https://wiki.archlinux.org/index.php/Stubby

let
  inherit (lib) mkOption mkIf types;
  cfg = config.services.privateDns;
in
{
  options = {
    services = {
      privateDns = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable DNS over TOR or TLS (a combination of tor, stubby, and dnsmasq).
            Don't use this unless you know what you are doing and understand how to test that it is set up correctly.
            '';
        };
        useTor = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Routes traffic over TOR instead of HTTPS. I think that you should probably only use this with a .onion dns provider
            like cloudflare in order to side-step any possible shenanigans at TOR exit nodes.
            '';
        };
        # topLevelNameServers = mkOption {
        #   type = types.listOf types.str;
        #   default = [ "1.1.1.1" "1.0.0.1" ];
        #   description = ''
        #     Name servers to use with the normal top-level domains that people are most familiar with for browsing the web.
        #     This uses cloudflare's 1.1.1.1 dns by default.
        #     '';
        # };
        # topLevelNameServersIpV6 = mkOption {
        #   type = types.listOf types.str;
        #   default = [ "2606:4700:4700::1111" "2606:4700:4700:1001" ];
        #   description = ''
        #     IP V6 name servers (defaults to cloudflare's name servers).
        #     '';
        # };
        specificNameServers = mkOption {
          type = types.attrsOf types.string;
          default = {};
          example = {
            "home" = "192.168.0.1";
            "work" = "192.168.1.1";
          };
          description = ''
            Name servers to use for specific domains (for example, to resolve subdomains in your home or work networks)
            '';
        };
      };
    };
  };
  config = mkIf cfg.enable {

    networking = {
      nameservers = [];
      hosts = lib.optionalAttrs cfg.useTor
        { "127.0.0.1" = [ "dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion" ]; };
    } // mkIf config.networking.networkmanager.enable {
      networkmanager.dns = "none";
    };

    services.tor = lib.optionalAttrs cfg.useTor {
      enable = true;
      client.enable = true;
      torsocks.enable = true;
    };

    # DNS-over-TLS resolver 
    services.stubby = {
      enable = true;
      listenAddresses = [ "127.0.0.1@53000" "0::1@53000" ];
      extraConfig = ''dnssec_trust_anchors: "${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf"'';
    } // lib.optionalAttrs cfg.useTor {
      authenticationMode = "GETDNS_AUTHENTICATION_NONE";
      upstreamServers = ''
        - address_data: 127.0.0.1
        '';
    } // lib.optionalAttrs (!cfg.useTor) {
        upstreamServers = ''
        - address_data: 1.1.1.1
          tls_auth_name: "cloudflare-dns.com"
          tls_pubkey_pinset:
                - digest: "sha256"
                  value: V6zes8hHBVwUECsHf7uV5xGM7dj3uMXIS9//7qC8+jU=
        - address_data: 2606:4700:4700::1111
          tls_auth_name: "cloudflare-dns.com"
          tls_pubkey_pinset:
                - digest: "sha256"
                  value: V6zes8hHBVwUECsHf7uV5xGM7dj3uMXIS9//7qC8+jU=
        - address_data: 1.0.0.1
          tls_auth_name: "cloudflare-dns.com"
          tls_pubkey_pinset:
                - digest: "sha256"
                  value: V6zes8hHBVwUECsHf7uV5xGM7dj3uMXIS9//7qC8+jU=
        - address_data: 2606:4700:4700::1001
          tls_auth_name: "cloudflare-dns.com"
          tls_pubkey_pinset:
                - digest: "sha256"
                  value: V6zes8hHBVwUECsHf7uV5xGM7dj3uMXIS9//7qC8+jU=
        '';
    };

    users.users = lib.optionalAttrs cfg.useTor {
      torsocks-dns-proxy =
        { name = "torsocks-dns-proxy";
          group = "torsocks-dns-proxy";
          description = "Proxy dns to tor.";
          isSystemUser = true;
        };
    };
    users.groups =
      lib.optionalAttrs cfg.useTor { torsocks-dns-proxy = {}; };

    systemd.services = lib.optionalAttrs cfg.useTor {
      "torsock-dns-proxy" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "tor.service" "network.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.socat}/bin/socat TCP4-LISTEN:853,reuseaddr,fork SOCKS4A:127.0.0.1:dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion:853,socksport=9050";
          # User = "torsocks-dns-proxy";
          # Group = "torsocks-dns-proxy";
          # AmbientCapabilities = "cap_net_bind_service";
          # CapabilityBoundingSet="cap_net_bind_service";
          User = "root";
          Group = "root";
          # NoNewPrivileges=yes
          # PrivateTmp=yes
          # PrivateDevices=yes
          # DevicePolicy=closed
          # ProtectSystem=strict
          # ProtectHome=read-only
          # ProtectControlGroups=yes
          # ProtectKernelModules=yes
          # ProtectKernelTunables=yes
          # RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK
          # RestrictRealtime=yes
          # RestrictNamespaces=yes
          # MemoryDenyWriteExecute=yes
        };
      };
    };


    # DNS masq check google first then VPN except for names in the top
    # level domain `.picofactory`
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      # Use stubby for most top-level dns resolution
      servers = [ "::1#53000" "127.0.0.1#53000" ];
      extraConfig =
        let
          serversString = lib.concatStringsSep "\n"
            (lib.mapAttrsToList (domain: serverIp: "server=/${domain}/${serverIp}")
              cfg.specificNameServers);
        in
          ''
          ${serversString}

          # ignore resolv.conf
          no-resolv
          # speed up queries for recent domains
          cache-size=300
          # only listen on localhost, not on public facing pi addresses
          listen-address=::1,127.0.0.1
          interface=lo
          bind-interfaces
          '' + lib.optionalString (!cfg.useTor)
            ''
            # forward dns validation provided by stubby
            proxy-dnssec
            '';
    };
  };
}
