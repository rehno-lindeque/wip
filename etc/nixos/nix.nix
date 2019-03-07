{ config
, ...
}:

let
  myhydraserver = # http://mydomain.com:3000; #gitignore
in
{
  nix = {
    # package = pkgs.nixUnstable; # ?

    buildCores = 6;     # allow many parallel tasks when building packages

    # perform nix garbage collection (delete unused programs) automatically for stuff older than 30 days 
    gc = {
      automatic = false;
      dates = "03:15"; # most people are asleep at 03:15 in the morning, so this might be a good time to run it
      options = "--delete-older-than 30d";
    };

    # this might be useful to you if you develop nix packages
    # * useChroot sandboxes your builds so that they are completely pure, but adds some overhead
    # * extraOptions are appended to your nix.conf (see https://nixos.org/wiki/FAQ#How_to_keep_build-time_dependencies_around_.2F_be_able_to_rebuild_while_being_offline.3F)
    # * build-cores = 0 means that the builder should use all available CPU cores in the system 
    # useChroot = true; # using the default false because this could be slow
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    ''
      # The following is helpful for deploying to raspberry pi 3
      # See https://botbot.me/freenode/nixos/2017-10-21/?msg=92566472&page=4
      # + ''
      #   build-extra-platforms = aarch64-linux
      # ''
      # optional, useful when the builder has a faster internet connection than yours
      + ''
      builders-use-substitutes = true
      ''
    ;

    # Uncomment to build distributed
    distributedBuilds = true;
    # Note that your local root must have the slave in ~/.ssh/known_hosts
    # TODO: use programs.ssh.knownHosts?
    buildMachines =
      [ # Automatically build arm expressions on my raspberry pi
        # { hostName = "192.168.0.11"; # home
        # { hostName = "192.168.100.228"; # work
        { hostName = "192.168.100.135"; # work-wifi
        # # { hostName = "192.168.0.12"; # home/work
          sshUser = "root"; # TODO: change
          sshKey = "/home/me/.ssh/id_accesspoint";
          system = "aarch64-linux";
          maxJobs = 1;
          supportedFeatures = [ "big-parallel" ];
        }
        # # Build stuff in a distributed fashion when at picofactory
        # # { hostName = "picofactory-conference"; # 192.168.1.141
        # { hostName = "192.168.1.141";
        #   sshUser = "picofactory-buildfarm";
        #   sshKey = "/home/me/.ssh/id_picofactory_buildfarm";
        #   system = "x86_64-linux";
        #   maxJobs = 1;
        # }
        # # { hostName = "picofactory-kitting"; # 192.168.1.129
        # { hostName = "192.168.1.129";
        #   sshUser = "picofactory-buildfarm";
        #   sshKey = "/home/me/.ssh/id_picofactory_buildfarm";
        #   system = "x86_64-linux";
        #   maxJobs = 1;
        # }
      ];


    # nixPath = [
    #   # Default nix paths
    #   "/nix/var/nix/profiles/per-user/root/channels/nixos"
    #   "nixos-config=/etc/nixos/configuration.nix"
    #   "/nix/var/nix/profiles/per-user/root/channels"
    #   # Added
    #   "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs"
    #   "nixpkgs-dev=${config.users.users.me.home}/projects/config/nixpkgs"
    # ];

    binaryCaches = [
      myhydraserver
      http://cache.nixos.org/
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "arm.cachix.org-1:fGqEJIhp5zM7hxe/Dzt9l9Ene9SY27PUyx3hT9Vvei0="
    ];
    requireSignedBinaryCaches = false; # Needed for personal hydra cache (at the moment)
    trustedBinaryCaches = [
      myhydraserver
      https://hydra.circuithub.com
      https://arm.cachix.org
    ];

    # TEMPORARY: for nix copy (aka nix-copy-closure)
    # trustedUsers = [ "root" "me" ];
  };
}

