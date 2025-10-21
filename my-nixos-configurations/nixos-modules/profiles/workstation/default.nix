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
      enable = mkEnableOption ''
        Whether to enable my functional workstation configuration profile.
        The purpose of this is to enable a basic level of functionality necessary to work with a system.
      '';
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
    fonts.enableDefaultPackages = lib.mkDefault true;

    home-manager.sharedModules = [
      {
        programs = {
          bash.enable = true;

          # Coding assistants
          claude-code.enable = true;
          claude-code.commands = {
            todo = ''
              ---
              description: Add TODO's to the code
              ---
              Reflect on this rough list of things that need doing: $ARGUMENTS

              Work out what we are trying to achieve and what code paths are relevant. Then carefully place TODO comments in the most relevant spots where those changes are likely to be implemented.
            '';
            reflect = ''
              ---
              description: Reflect on the best way to implement something.
              ---
              Reflect on this next task:

              $ARGUMENTS

              Can you please give me a few different options that covers the entire design space well? Order them from most likely to least likely.
            '';
            refactor = ''
              ---
              description: Reflect on the best refactor for achieving the next tasks.
              ---
              Reflect on the next tasks that need to be done. What problems will we run into if we try to implement them with the current state of our implementation?

              Instead of tackling the next task directly, let's refactor the code at an architectural level in order to support the next change(s) we'll need to make.

              Can you please propose a few different options that covers the entire design space well? Order them from most likely to least likely.
            '';
            deep-reflect = ''
              ---
              description: Reflect on the best way to implement something.
              ---
              Reflect on this next task:

              $ARGUMENTS

              Can you please give me a few different options that covers the entire design space well? Order them from most likely to least likely.

              Finally, once you are done, take a step back and consider if this is even the right thing to be working on? Is there an unexpectedly simple approach to solving the high level problem that we're not considering?
            '';
          };
          claude-code.mcpServers.github = {
            type = "http";
            url = "https://api.githubcopilot.com/mcp/";
          };
          claude-code.settings = {
            includeCoAuthoredBy = false;
          };
          codex.enable = true;

          # Fuzzy find file names
          fzf.enable = lib.mkDefault true;

          # Neovim, configured as an IDE
          neovim = {
            enable = lib.mkDefault true;
            plugins = with config.profiles.preferences.customizedVimPlugins; [
              # Programming language integrations: Language servers
              nvim-lspconfig

              # Code editing: Comment and uncomment
              vim-commentary

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

              # Git support: Show changed lines in gutter
              gitsigns-nvim

              # Nix support
              vim-nix

              # Navigation: Fuzzy finder
              telescope-nvim
              telescope-fzf-native-nvim

              # Navigation: File tree
              nvim-tree-lua

              # Navigation: Buffers
              bufferline-nvim

              # Aesthetics: Color scheme
              gruvbox-nvim

              # Aesthetics: icons
              nvim-web-devicons

              # Aesthetics: Status/tabline
              lualine-lsp-progress
              lualine-nvim

              # Vim: key binding feedback
              which-key-nvim

              # Vim: benchmarking
              vim-startuptime
            ];

            extraPackages = with pkgs; [
              # Language server packages (executables)
              nixd
              haskell-language-server
              lua-language-server
              elmPackages.elm-language-server
            ];
          };
        };
      }
    ];

    # Currently I always use network manager for convenience
    # (However, this is something I'm still evaluating)
    # nmtui or nmcli can be used to control network manager
    networking.networkmanager.enable = lib.mkDefault true;

    # Allow routing through tailscale subnets
    # See https://github.com/tailscale/tailscale/issues/4432
    networking.firewall = lib.mkIf config.services.tailscale.enable {
      checkReversePath = "loose";
    };

    # Don't eliminate build dependencies or derivations for live paths during garbage-collection
    # https://nixos.wiki/wiki/FAQ#How_to_keep_build-time_dependencies_around_.2F_be_able_to_rebuild_while_being_offline.3F
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    services = {
      tailscale.enable = lib.mkDefault true;
    };

    # Security
    security.apparmor.enable = lib.mkDefault true;
    services.openssh.enable = lib.mkDefault false;
    services.openssh.settings.PermitRootLogin = lib.mkDefault "no";
    services.openssh.settings.PasswordAuthentication = lib.mkDefault false;
    services.fail2ban.enable = lib.mkDefault true;

    # Note that locking the kernel modules can sometimes prevent you from doing useful things
    # like mounting new filesystems.
    # Override when needed.
    security.lockKernelModules = lib.mkDefault true;
  };
}
