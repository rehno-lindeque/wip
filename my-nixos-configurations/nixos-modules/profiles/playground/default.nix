{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.playground;
in {
  options = with lib; {
    profiles.playground = {
      enable = mkEnableOption ''
        Whether to enable my personal playground.
        This includes services, packages, options, and other cruft that I'm
        trying out, but haven't committed to keeping longer term.
      '';
    };
  };

  config =
    lib.mkIf cfg.enable
    (lib.mkMerge [
      (lib.mkIf config.profiles.preferences.enable {
        # # Keyboard layouts that I use (TODO: there may be a better way to set this up)
        # environment.systemPackages = let
        #   norman = pkgs.writeScriptBin "norman" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us -variant norman
        #   '';
        #   qwerty = pkgs.writeScriptBin "qwerty" ''
        #     ${pkgs.xorg.setxkbmap}/bin/setxkbmap us
        #   '';
        # in [
        #   norman
        #   qwerty
        # ];

        # TODO: should this be a preference setting for e.g. some terminal?
        # TODO: check where fonts are used (vim?)
        # TODO: Check against any home-manager font settings?
        # TODO: Check against i18n.consoleFont ?
        # fonts.fonts = with pkgs; [
        #   source-code-pro
        #   terminus-nerdfont
        #   inconsolata-nerdfont
        #   firacode-nerdfont ?
        #   source-code-pro-nerdfont ?
        #   fira-code
        #   iosevka
        #   terminus_font
        # ];

        home-manager = {
          users.me = {pkgs, ...}: {
            home.shellAliases = {
              # Edit all files modified relative to a recent git commit
              virecent = ''vi $(git diff HEAD~1 --relative --name-only)'';

              # Edit all unmerged files containing git conflicts
              viconflict = ''vi $(git status -s | grep \\\(UU\\\|AA\\\) | sed "s/^\(UU\|AA\) //")'';
            };
            programs = {
              starship = {
                enable = true;
                enableBashIntegration = true;
                settings = {
                  #   add_newline = false;
                  #   format = lib.concatStrings [
                  #     "$line_break"
                  #     "$package"
                  #     "$line_break"
                  #     "$directory"
                  #     "$git_branch"
                  #     "$node"
                  #     "$rust"
                  #     "(bold green)"
                  #   ];
                  #   scan_timeout = 10;
                  #   directory.format = "[$path]($style) ";
                  #   time.disabled = true;

                  #   # # See docs here: https://starship.rs/config/
                  #   # # Symbols config configured ./starship-symbols.nix.
                  #   # battery.display.threshold = 25; # display battery information if charge is <= 25%
                  #   # directory.fish_style_pwd_dir_length = 1; # turn on fish directory truncation
                  #   # directory.truncation_length = 2; # number of directories not to truncate
                  #   # gcloud.disabled = true; # annoying to always have on
                  #   # hostname.style = "bold green"; # don't like the default
                  #   # memory_usage.disabled = true; # because it includes cached memory it's reported as full a lot
                  #   # username.style_user = "bold blue"; # don't like the default

                  #   # symbols
                  #   aws.symbol = lib.mkDefault " ";
                  #   battery.full_symbol = lib.mkDefault "";
                  #   battery.charging_symbol = lib.mkDefault "";
                  #   battery.discharging_symbol = lib.mkDefault "";
                  #   battery.unknown_symbol = lib.mkDefault "";
                  #   battery.empty_symbol = lib.mkDefault "";
                  #   cmake.symbol = lib.mkDefault "△ ";
                  #   conda.symbol = lib.mkDefault " ";
                  #   crystal.symbol = lib.mkDefault " ";
                  #   dart.symbol = lib.mkDefault " ";
                  #   directory.read_only = lib.mkDefault " ";
                  #   docker_context.symbol = lib.mkDefault " ";
                  #   dotnet.symbol = lib.mkDefault " ";
                  #   elixir.symbol = lib.mkDefault " ";
                  #   elm.symbol = lib.mkDefault " ";
                  #   erlang.symbol = lib.mkDefault " ";
                  #   gcloud.symbol = lib.mkDefault " ";
                  #   git_branch.symbol = lib.mkDefault " ";
                  #   git_commit.tag_symbol = lib.mkDefault " ";
                  #   git_status.format = lib.mkDefault "([$all_status$ahead_behind]($style) )";
                  #   git_status.conflicted = lib.mkDefault " ";
                  #   git_status.ahead = lib.mkDefault " ";
                  #   git_status.behind = lib.mkDefault " ";
                  #   git_status.diverged = lib.mkDefault " ";
                  #   git_status.untracked = lib.mkDefault " ";
                  #   git_status.stashed = lib.mkDefault " ";
                  #   git_status.modified = lib.mkDefault " ";
                  #   git_status.staged = lib.mkDefault " ";
                  #   git_status.renamed = lib.mkDefault " ";
                  #   git_status.deleted = lib.mkDefault " ";
                  #   golang.symbol = lib.mkDefault " ";
                  #   helm.symbol = lib.mkDefault "⎈ ";
                  #   hg_branch.symbol = lib.mkDefault " ";
                  #   java.symbol = lib.mkDefault " ";
                  #   julia.symbol = lib.mkDefault " ";
                  #   kotlin.symbol = lib.mkDefault " ";
                  #   kubernetes.symbol = lib.mkDefault "☸ ";
                  #   lua.symbol = lib.mkDefault " ";
                  #   memory_usage.symbol = lib.mkDefault " ";
                  #   nim.symbol = lib.mkDefault " ";
                  #   nix_shell.symbol = lib.mkDefault " ";
                  #   nodejs.symbol = lib.mkDefault " ";
                  #   openstack.symbol = lib.mkDefault " ";
                  #   package.symbol = lib.mkDefault " ";
                  #   perl.symbol = lib.mkDefault " ";
                  #   php.symbol = lib.mkDefault " ";
                  #   purescript.symbol = lib.mkDefault "<≡> ";
                  #   python.symbol = lib.mkDefault " ";
                  #   ruby.symbol = lib.mkDefault " ";
                  #   rust.symbol = lib.mkDefault " ";
                  #   shlvl.symbol = lib.mkDefault " ";
                  #   status.symbol = lib.mkDefault " ";
                  #   status.not_executable_symbol = lib.mkDefault " ";
                  #   status.not_found_symbol = lib.mkDefault " ";
                  #   status.sigint_symbol = lib.mkDefault " ";
                  #   status.signal_symbol = lib.mkDefault " ";
                  #   swift.symbol = lib.mkDefault " ";
                  #   terraform.symbol = lib.mkDefault "𝗧 ";
                  #   vagrant.symbol = lib.mkDefault "𝗩 ";
                  #   zig.symbol = lib.mkDefault " ";
                };
              };
              neovim = {
                extraConfig = ''
                  luafile ${./neovim/playground.lua}
                '';
                plugins = with pkgs.vimPlugins; let
                  context-vim = pkgs.vimUtils.buildVimPlugin {
                    name = "context-vim";
                    src = pkgs.fetchFromGitHub {
                      owner = "wellle";
                      repo = "context.vim";
                      rev = "e38496f1eb5bb52b1022e5c1f694e9be61c3714c";
                      sha256 = "1iy614py9qz4rwk9p4pr1ci0m1lvxil0xiv3ymqzhqrw5l55n346";
                    };
                  };
                in [
                  # Code editing: Delete surrounding brackets, quotes, etc
                  # TODO: Does this load slowly
                  vim-sandwich

                  # Aesthetics: context formatting
                  # TODO: Does this slow down terminal rendering / increase flickering?
                  # let g:context_nvim_no_redraw = 1 # perhaps fixed by this?
                  # context-vim

                  # Aesthetics: advanced syntax highlighting
                  # TODO: this plugin states that it is still experimental
                  # nvim-treesitter

                  # Aesthetics: Interactivity
                  # {
                  #   plugin = my-custom-interactivity;
                  #   type = "lua";
                  #   config = ''
                  #     local group = vim.api.nvim_create_augroup('aesthetics', { clear = true })
                  #     vim.api.nvim_create_autocmd('InsertEnter', {
                  #       desc = 'increase cursorline highlight in insert mode',
                  #       -- callback = function() vim.highlight.create('CursorLineNr', { guibg="#16161e" }) end,
                  #       -- callback = function() vim.highlight.create('CursorLineNr', { guifg="#ffffff" }) end,
                  #       callback = function() vim.highlight.link('CursorLineNr', 'User2', true) end,
                  #       group = group,
                  #     })
                  #   '';
                  # }
                  # vim.api.nvim_create_autocmd('InsertEnter', {
                  #   desc = 'increase cursorline highlight in insert mode',
                  #   callback = function() vim.highlight.create('CursorLine', { ctermbg=253 }) end,
                  # })
                ];
              };
            };
          };
          #   # Uncategorized
          #   ++ [
          #     # telescope-nvim
          #     # nvim-autopairs
          #     # vim-vsnip
          #     # nvim-web-devicons
          #     # nvim-tree-lua
          #   ];
        };
      })

      (lib.mkIf config.profiles.nucbox.enable {
        # TODO: clean up / check sound (it doesn't work right now)
        # hardware.pulseaudio.daemon.logLevel = "error";
        # hardware.pulseaudio.support32Bit = lib.mkDefault true;

        # Since I normally use this computer in headless mode it's convenient to have it Wake-On-Lan
        # TODO: test and also check the bios setting
        # Tailscale could be used when https://github.com/tailscale/tailscale/issues/306 is resolved
        # To wake it up:
        # wol 00:e0:4c:68:0f:e8
        # or
        # wol 192.168.1.12
        # networking.interfaces.enp0s21f0u2u1.wakeOnLan.enable = true;

        # Set the desktop manager to none so that it doesn't default to xterm sometimes
        # TODO: check if this is this still needed?
        # xserver.displayManager.defaultSession = "none+xmonad";

        # Enable fzf bash integration
        programs.fzf.enableBashIntegration = true;

        # Security
        services.gnome.gnome-keyring.enable = true; # gnome's default keyring

        # Set a low brightness for my displays at night
        services.redshift = {
          temperature.night = 2750;
          brightness.night = "0.5";
        };
      })
    ]);
}
