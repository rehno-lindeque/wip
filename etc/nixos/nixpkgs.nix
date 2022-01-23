{ pkgs
, config
, nixos
, lib
, ...
}:

let
  originalPkgs = import <nixpkgs> {};
  patches = [
    # (builtins.fetchurl {
    #   name = "triggerhappy.patch";
    #   url = "https://github.com/NixOS/nixpkgs/commit/13f640057d8873a91fdf4cd804c96cd03fe63bd4.patch";
    #   sha256 = "1j6qgqf7w2zh58rlya1siacp7yi9v1k39ra728h7na4h0qgjpim6";
    # })
    # (builtins.fetchurl {
    #   name = "triggerhappy-service.patch";
    #   url = "https://github.com/NixOS/nixpkgs/pull/45109.patch";
    #   sha256 = "1yv5fy824v9q00rkdvx6dg4dmn9f95j00wiap8ajz9g8sf2xmb3m";
    # })
    # KiCAD https://github.com/NixOS/nixpkgs/commits/9cff865230d65cbb650187ca0d1cb6034e37ecd6/pkgs/applications/science/electronics/kicad/default.nix
    # (builtins.fetchurl {
    #   name = "kicad-5.0.0.patch";
    #   url = "https://github.com/NixOS/nixpkgs/commit/9cff865230d65cbb650187ca0d1cb6034e37ecd6.patch";
    #   sha256 = "13xnb99jf8h6v9y40pbva64qynmmpd62l60pwp30c7djpp2zpprs";
    # })
    # (builtins.fetchurl {
    #   name = "kicad-5.0.0.patch";
    #   url = "https://github.com/rehno-lindeque/nixpkgs/commit/805ea2480411b2973f111a9fa26c1adad4de63ce.patch";
    #   sha256 = "0hqj21nym9491jk20dihd0bdmndr1vc3im6i3323wn3ww3jf3w5m";
    # })
    # (builtins.fetchurl {
    #   name = "addOpenGLRunpath.patch";
    #   url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/60985.patch";
    #   sha256 = "0vwdxqf1mv5psjz7y9q1rpfn5vd4kgsihbcf9psvakziw7cf03hp";
    # })
    # (builtins.fetchurl {
    #   name = "teensyduino.patch";
    #   url = "https://github.com/rehno-lindeque/nixpkgs/commit/5663fac4f3a79f096c3ce73581cabab1ebd98577.patch";
    #   sha256 = "0ywnpz2dnbis7w3ji79i8cvw28j4yw0syhfqj6s5jbj75m6lx601";
    # })
  ];
  nixpkgsVersion = lib.fileContents <nixpkgs/.version>;
  nixpkgsVersionSuffix = lib.fileContents <nixpkgs/.version-suffix>;
  patchedPkgs =
    originalPkgs.runCommand "nixpkgs-${nixpkgsVersion}${nixpkgsVersionSuffix}" {
      originalPkgs = originalPkgs.path;
      inherit patches;
    } ''
      cp -r $originalPkgs $out
      chmod -R +w $out
      for p in $patches; do
        echo "Applying patch $p";
        patch -d $out -p1 < "$p";
      done
    '';
in
{
  nixpkgs = {
    config = {
      # Enable unfree packages
      allowUnfree = true;

      # Non-overlay overrides
      # packageOverrides = pkgs: {
      #   # See https://nixos.wiki/wiki/Cheatsheet#Customizing_Packages
      #   # unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
      # };
    };
    overlays = [
      (import ./overlay.nix)
      # (import "${nixpkgs-mozilla}/rust-overlay.nix")
      # (import "/home/me/projects/development/ml-papers-pkgs/overlay.nix") #gitignore
    ];
    # pkgs = import patchedPkgs {
    #   inherit (config.nixpkgs) config overlays system;
    # };
  };
}
