{
  flake,
  mkHelp,
  system,
  writeScript,
}: let
  nc = "\\e[0m"; # No Color
  white = "\\e[1;37m";
  yellow = "\\e[1;33m";
in {
  help = {
    type = "app";
    description = "display this help message";
    program =
      (mkHelp {
        name = "wip";
        inherit flake system writeScript;
        additionalCommands = {
        };
        supplementalNotes = ''
        '';
      })
      .outPath;
  };
}
