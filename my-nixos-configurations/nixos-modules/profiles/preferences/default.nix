{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.profiles.preferences;
  # neovimPluginType = options.home-manager.programs.neovim.plugins.nestedTypes.elemType; # TODO: how to retrieve this type?
  neovimPluginType = with lib; types.either types.package types.attrs;
in {
  options = with lib; {
    profiles.preferences = {
      enable = mkEnableOption ''
        Whether to enable my personal nice-to-have customizations.
        Preferences are not specific to my own user, accounts, keys, etc.
        Additionally, no services are turned on and no packages are installed.
      '';
      customizedVimPlugins = mkOption {
        type = types.lazyAttrsOf neovimPluginType;
        internal = true;
        default = pkgs.vimPlugins;
        defaultText = "pkgs.vimPlugins // customizedVimPlugins";
        description = ''
          Plugin configurations with customizations, including keymaps and aesthetics.
          Use this with <option>programs.neovim.plugins</option>.
          For example:
          <code>plugins = with config.profile.preferences.customizedVimPlugins; [ nvim-cmp ]</code>

          My philosophical take on vim configuration:
          * Less is more: focus on things I "need" for productivity when deviating from default configurations
          * I like to "live in the future", which means using lua plugins, lua config etc
          * If I'm not actively using something, then it doesn't belong in my config
          * If I can't remember the key binding, reconsider it
          * Simplicity and performance/robustness characteristics are features #1, and #2 when evaluating plugins
          * Config should be explainable at a glance
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Clear the /tmp directory when the system is rebooted
    boot.cleanTmpDir = lib.mkDefault true;

    profiles.preferences.customizedVimPlugins =
      pkgs.vimPlugins
      // (with pkgs.vimPlugins; {
        # Code editing: Comment and uncomment
        vim-commentary = {
          plugin = vim-commentary;
        };

        # Programming language integrations: Language servers
        nvim-lspconfig = {
          plugin = nvim-lspconfig;
          type = "lua";
          # plugin = nvim-lspconfig.overrideAttrs (oldAttrs: {
          #   dependencies = (old.dependencies or [ ]) ++ [
          #     # lsp_extensions-nvim
          #     # lsp_signature-nvim
          #     # lua-dev-nvim
          #     # SchemaStore-nvim
          #   ];
          # });
          config =
            ''
              loadfile('${./neovim/plugins/lspconfig.lua}')()
            '';
        };

        # Code editing: Auto-completion
        nvim-cmp = {
          plugin = nvim-cmp;
          type = "lua";
          config =
            # Note caveats in the readme regarding native menu
            ''
              local cmp = require('cmp')
              cmp.setup({
                snippet = {
                  expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                  end,
                },
                mapping = cmp.mapping.preset.insert({
                  -- Accept the currently selected item
                  ['<CR>'] = cmp.mapping.confirm({ select = true }),

                  -- Force auto-completion in insert mode without first typing something
                  ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
                }),
                sources = cmp.config.sources({
                  -- Listed in order of preference
                  { name = 'nvim_lua' },
                  { name = 'nvim_lsp' },
                  { name = 'luasnip' },
                  { name = 'buffer' },
                })
              })

              vim.opt.completeopt = {
                -- Show the completion menu for a single match so that documentation will always appear
                "menuone",

                -- Don't pop open documentation unless you explicitly navigate the completion menu
                "noselect",
              }

              -- Suppress command-line noise related to completions
              vim.opt.shortmess:append "c"
            '';
        };

        # Code editing: Auto-completion with current buffer contents
        cmp-buffer = {
          plugin = cmp-buffer;
          type = "lua";
          config = ''
            -- Use buffer as a completion source for search via /
            require('cmp').setup.cmdline('/', {
              sources = {
                { name = 'buffer' }
              }
            })
          '';
        };

        # Code editing: Auto-completion with language servers
        cmp-nvim-lsp = {
          plugin = cmp-nvim-lsp;
        };

        # Code editing: Auto-completion with nvim's lua api
        cmp-nvim-lua = {
          plugin = cmp-nvim-lua;
        };

        # Git support
        vim-fugitive = {
          plugin = vim-fugitive;
        };

        # Git support: Show changed lines in gutter (replaces gitgutter)
        gitsigns-nvim = {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            loadfile('${./neovim/plugins/gitsigns.lua}')()
          '';
        };

        # Nix support
        vim-nix = {
          plugin = vim-nix;
        };

        # Navigation: Fuzzy finder
        telescope-nvim = {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            -- Search file names that are tracked by git
            vim.keymap.set('n', '<leader>o', function() return require('telescope.builtin').git_files() end, { desc = "Search tracked files" })

            -- Search file names modified relative to HEAD
            vim.keymap.set('n', '<leader>m', function() return require('telescope.builtin').git_status() end, { desc = "Search modified files" })

            -- Search file names
            vim.keymap.set('n', '<leader>O', function() return require('telescope.builtin').find_files() end, { desc = "Search files" })

            -- Search file contents
            vim.keymap.set('n', '<leader>/', function() return require('telescope.builtin').live_grep() end, { desc = "Search files contents" })

            -- Search buffer names
            vim.keymap.set('n', '<leader>b', function() return require('telescope.builtin').buffers() end, { desc = "Search open buffers" })

            -- Search diagnostics in all open buffers
            vim.keymap.set('n', '<leader>D', function() return require('telescope.builtin').diagnostics() end, { desc = "Search workspace diagnostics" })

            -- Search diagnostics
            vim.keymap.set('n', '<leader>d', function() return require('telescope.builtin').diagnostics({ bufnr = 0 }) end, { desc = "Search diagnostics" })

            -- Search vim help
            vim.keymap.set('n', '<leader>hh', function() return require('telescope.builtin').help_tags() end, { desc = "Search vim help" })

            -- Pressing esc twice to cancel is annoying, so map <esc> to directly close the popup in insert mode
            local actions = require('telescope.actions')
            require('telescope').setup({
              defaults = {
                mappings = {
                  i = {
                    ["<esc>"] = actions.close,
                  },
                },
              },
            })
          '';
        };
        telescope-fzf-native-nvim = {
          # native fzf ostensibly improves performance
          plugin = telescope-fzf-native-nvim;
          type = "lua";
          config = ''
            require('telescope').load_extension('fzf')
          '';
        };

        # Navigation: File tree
        nvim-tree-lua = {
          plugin = nvim-tree-lua;
          type = "lua";
          config = ''
            require('nvim-tree').setup({
            })
          '';
        };

        # Navigation: Tabline
        bufferline-nvim = {
          plugin = bufferline-nvim;
          type = "lua";
          config = ''
            require('bufferline').setup({
              options = {
                -- Needed because vim buffers are different from vim tab pages.
                -- This is the same as setting vim.opt.showtabline = 2.
                always_show_bufferline = true,
              },
            })
          '';
        };

        # Aesthetics: Color scheme
        gruvbox-nvim = {
          # faster than gruvbox and gruvbox-community
          plugin = gruvbox-nvim;
          type = "lua";
          config = ''
            vim.cmd [[colorscheme gruvbox]]

            -- TODO: move to playground
            -- "Hide" the cursor line highlight past column 80 and 120 to hint at potential text wrap.
            vim.o.colorcolumn=vim.fn.join(vim.fn.range(81,121), ',') .. vim.fn.join(vim.fn.range(121,999), ',')
            vim.highlight.link('ColorColumn', 'Normal', true)
          '';
        };

        # Aesthetics: icons
        nvim-web-devicons = {
          plugin = nvim-web-devicons;
        };

        # Aesthetics: status/tabline
        lualine-nvim = {
          plugin = lualine-nvim.overrideAttrs (oldAttrs: {
            dependencies =
              (oldAttrs.dependencies or [])
              ++ [
                lualine-lsp-progress
              ];
          });
          type = "lua";
          config = ''
            require('lualine').setup({
             sections = {
               lualine_a = { { 'mode', upper = true } },
               lualine_b = { { 'branch', icon = '' } },
               lualine_c = {
                  { 'filename', file_status = true, path = 1 },
                  { 'diagnostics', sources = { 'nvim_lsp' } },
                  { 'lsp_progress' },
               },
               lualine_x = { 'encoding', 'filetype' },
               lualine_y = { 'progress' },
               lualine_z = { 'location' },
             },
            })

            -- Suppress mode prefixes like "-- INSERT --" in the command-line
            vim.opt.showmode = false
          '';
        };

        # Vim: key binding feedback
        which-key-nvim = {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            require('which-key').setup({
            })
          '';
        };

        # Vim: benchmarking
        vim-startuptime = {
          # Run with vim --startuptime
          plugin = vim-startuptime;
        };
      });

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        ({system, ...}: {
          home = {
            enableNixpkgsReleaseCheck = true;
            sessionVariables = {
              # Various terminal programs like git use EDITOR for automatically running a text editor
              EDITOR = "vim";
            };
          };
          programs = {
            bash = {
              # Auto-completion in bash (See https://github.com/nix-community/home-manager/issues/1464)
              # enableCompletion = true;

              # Prefix bash commands with a space character to avoid adding them to recorded history
              historyControl = ["ignorespace"];
            };
            viAlias = true;
            neovim = {
              viAlias = true;
              vimAlias = true;
              extraConfig = ''
                luafile ${./neovim/options.lua}
                luafile ${./neovim/keymap.lua}
              '';
            };
          };
        })
      ];
    };

    nix = {
      # Helpful for supplying remote builder options, nix copy, etc
      trustedUsers = ["root" "@wheel"];
    };

    programs = {
      git.config = {
        init.defaultBranch = "main";
        url."https://github.com/".insteadOf = ["gh:" "github:"];
      };
      ssh = {
        startAgent = lib.mkDefault true;
        agentTimeout = "1h";
      };
    };
  };
}
