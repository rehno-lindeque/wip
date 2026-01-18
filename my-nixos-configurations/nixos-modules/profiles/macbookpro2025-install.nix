{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.macbookpro2025Install;
in {
  options = with lib; {
    profiles.macbookpro2025Install = {
      enable = mkEnableOption ''
        Installer variant for macbookpro2025: use the base profile, but strip extras and auto-format /nix.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Base hardware profile (keeps impermanence/layout)
    profiles.macbookpro2025.enable = true;

    # Force off heavier optional layers for the installer
    profiles.workstation.enable = lib.mkForce false;
    profiles.preferences.enable = lib.mkForce false;
    profiles.personalized.enable = lib.mkForce false;
    profiles.playground.enable = lib.mkForce false;

    # Auto-format the /nix partition on first boot of the installer
    fileSystems."/nix".autoFormat = lib.mkForce true;

    # Installer-friendly access; tighten later
    users.mutableUsers = false;
    users.users.root.hashedPassword =
      "$6$vLC4X1jGTMwqv835$qe3.gqt6tqlPW4SVsefbn9hiI6ynY8MWQFq4YymYdq7HI6tuHWYDWyX6NHp7OykQnyBoTG6VrgultN9iP4SCY/";

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = true;
      };
    };
  };
}
