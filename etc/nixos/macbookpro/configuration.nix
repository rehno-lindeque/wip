{
  pkgs
, ...
}:

{
  imports =
    [
      ../macbook/configuration.nix
      ./services.nix
    ];
}
