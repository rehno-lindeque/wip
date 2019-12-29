{ config, lib, pkgs, ... }:

# See https://nixos.wiki/wiki/Yubikey

with lib;
let
  cfg = config.hardware.yubikey;
in
{
  options = {
    hardware.yubikey = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable yubikey services and udev rules.
          By default, a yubikey group is created for this purpose.
        '';
      };
      # group = mkOption {
      #   type = types.str;
      #   default = "yubikey";
      #   example = "users";
      #   description = ''
      #     Grant access to yubikey devices to users in this group.
      #   '';
      # };
      # sshSupport = mkOption {
      #   type = types.bool;
      #   default = false;
      # }
    };
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };

  # environment.shellInit = ''
  #   export GPG_TTY="$(tty)"
  #   gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  # '';
  
  # programs = {
  #   ssh.startAgent = false;
  #   gnupg.agent = {
  #     enable = true;
  #     enableSSHSupport = true;
  #   };
  # };
}

