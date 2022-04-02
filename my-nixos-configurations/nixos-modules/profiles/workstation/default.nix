{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.workstation;
in {
  options = with lib; {
    profiles.workstation = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable my basic workstation configuration profile.
          The purpose of this is to enable a basic level of functionality necessary to work with a system.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # A tmpfs file system comes in handy if you don't want files to touch
    # your hard drive at all.
    fileSystems."/tmp/ram" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["size=5m"];
    };

    # Any reasonable workstation probably at least needs some basic quality of life fonts
    fonts.enableDefaultFonts = lib.mkDefault true;

    # TODO: should this be a preference setting for e.g. some terminal?
    # TODO: check where this font is used (vim?)
    # TODO: Check against any home-manager font settings?
    # fonts.fonts = with pkgs; [source-code-pro];
    home-manager.sharedModules = [
      {
        programs = {
          # It's difficult to get much done without some flavour of vi available
          neovim = {
            enable = lib.mkDefault true;
            plugins = with config.profiles.preferences.customizedVimPlugins; [
              # Code editing: Comment and uncomment
              vim-commentary

              # Programming language integrations: Language servers
              nvim-lspconfig

              # Code editing: Auto-completion
              nvim-cmp

              # Code editing: Auto-completion with language servers
              cmp-nvim-lsp

              # Code editing: Auto-completion with current buffer contents
              cmp-buffer

              # Code editing: Auto-completion with nvim's lua api
              cmp-nvim-lua

              # Code editing: Auto-completion with current buffer contents
              cmp-buffer

              # Git support
              vim-fugitive

              # Git support: show changed lines in gutter
              gitsigns-nvim

              # Nix support
              vim-nix

              # Fuzzy finder
              telescope-nvim
              telescope-fzf-native-nvim

              # Aesthetics: Color scheme
              gruvbox-nvim
            ];
          };
        };
      }
    ];

    # Currently I always use network manager for convenience
    # (However, this is something I'm still evaluating)
    # nmtui or nmcli can be used to control network manager
    networking.networkmanager.enable = lib.mkDefault true;

    # Don't eliminate build dependencies or derivations for live paths during garbage-collection
    # https://nixos.wiki/wiki/FAQ#How_to_keep_build-time_dependencies_around_.2F_be_able_to_rebuild_while_being_offline.3F
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    services = {
      tailscale.enable = lib.mkDefault true;
      tor.enable = lib.mkDefault true;
      tor.client.enable = lib.mkDefault true;
    };

    # Security
    security.apparmor.enable = lib.mkDefault true;
    services.openssh.enable = lib.mkDefault false;
    services.fail2ban.enable = lib.mkDefault true;

    # Note that locking the kernel modules can sometimes prevent you from doing useful things
    # like mounting new filesystems.
    # Override when needed.
    security.lockKernelModules = lib.mkDefault true;
  };
}
