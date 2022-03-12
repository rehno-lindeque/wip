{
  flake,
  mkHelp,
  system,
  writeScript,
}: let
  nc = "\\e[0m"; # No Color
  white = "\\e[1;37m";
  yellow="\\e[1;33m";
in {
  help = {
    type = "app";
    description = "display this help message";
    program =
      (mkHelp {
        name = "my-nixos-configurations";
        inherit flake system writeScript;
        additionalCommands = {
          "lsblk" = "check which device holds your thumb drive";
        };
        supplementalNotes = ''
          INSTALLER INSTRUCTIONS:

          Use dd to overwrite usb media with the iso image contents (${yellow}carefully!${nc}):

          ${white}sudo dd if=./result/iso/installer-${system}.iso of=/dev/sd${yellow}X${white} bs=1MB${nc}
        '';
      })
      .outPath;
  };

  build-installer-iso = {
    type = "app";
    description = "build an iso image";
    program =
      (writeScript "build-installer-iso" ''
        nix build ${../.}#nixosConfigurations.installer.config.system.build.isoImage
      '')
      .outPath;
  };
}
