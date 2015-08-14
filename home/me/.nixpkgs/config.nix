{ pkgs
, ... 
}:

# Use
#   $ nix-env -u
# to update

let devpkgs = import <devpkgs> {}; 
    # yipkgs = pkgs.haskell.packages.ghc7101.ghcWithPackages 
    #            (ps: with ps; [
    #                yi
    #                yi-language  # collection of language plugins for yi
    #                yi-contrib # collection of usefull plugins
    #            ]);
in
{ 
  allowUnfree = true;

  # packageOverrides = super: {
  #   yi-custom = import ./yi-custom.nix { pkgs = devpkgs; };
  # };
 
  # environment = {
  #   systemPackages = with pkgs ; [
  #     yi-custom
  #   ];
  # };

}
