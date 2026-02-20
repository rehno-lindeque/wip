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
        Installer variant for macbookpro2025: use the base profile, but strip extras.
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

    # Skip /etc persistence during install to avoid activation failures; full system re-enables it.
    environment.persistence."/nix/persistent".files = lib.mkForce [];

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

    hardware.asahi.peripheralFirmwareDirectory =
      lib.mkForce "/mnt/nix/persistent/etc/nixos/firmware";

    # Avoid persist-files conflicts during installer activation.
    environment.persistence."/nix/persistent".files = lib.mkForce [];
  };
}
