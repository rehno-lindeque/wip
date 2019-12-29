{ striata-reader, buildFHSUserEnv }:

buildFHSUserEnv {
  name = "striata-reader-env";
  targetPkgs = pkgs: with pkgs; [
    striata-reader
  ];
  runScript = "bash";
}
