{ config
, ...
}:

{
  nix = {
    # package = pkgs.nixUnstable; # ?

    buildCores = 6;     # allow many parallel tasks when building packages

    # perform nix garbage collection (delete unused programs) automatically for stuff older than 30 days 
    gc = {
      automatic = true;
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
    '';

    binaryCaches = [
      # using hydra.cryp.to based on https://github.com/NixOS/nixpkgs/issues/7792#issuecomment-100887882
      # also be aware of this bug: https://nixos.org/wiki/Haskell#Recovering_from_GHC.27s_non-deterministic_library_ID_bug
      http://hydra.cryp.to                    # a bunch of people seem to have this one, is it a mirror of hydra.nixos.org ?  
      # http://hydra.nixos.org                # seems to be the standard build server?
      # http://cache.nixos.org                # many people have this one, but I'm not sure whether it will work well for the unstable channel? see bendlas/nixos-config/nixpkgs-config.nix
    ];
    trustedBinaryCaches = [
      http://hydra.cryp.to
      # http://hydra.nixos.org
      # http://cache.nixos.org
    ];

  };
}
