{ pkgs
, ...
}:

{
  nixpkgs = {
    config = {
      # Enable unfree packages
      allowUnfree = true;
    };
  };
}
