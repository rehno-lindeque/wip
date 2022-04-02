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
          * 1 part discipline, 1 part pragmatism
          * If I'm not actively using something, then it doesn't belong in my config
          * If I can't remember the key binding, reconsider it
          * I like to "live in the future", which means using lua plugins, lua config etc
          * Simplicity and performance/robustness characteristics are features #1, and #2 when evaluating plugins
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
          # plugin = nvim-lspconfig.overrideAttrs (oldAttrs: {
          #   dependencies = (old.dependencies or [ ]) ++ [
          #     # lsp_extensions-nvim
          #     # lsp_signature-nvim
          #     # lua-dev-nvim
          #     # SchemaStore-nvim
          #   ];
          # });
          # config = ''
          #   require('${./neovim/plugins/lspconfig.lua}')
          # '';
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
                mapping = {
                  -- Accept the currently selected item
                  ['<CR>'] = cmp.mapping.confirm({ select = true }),

                  -- Force auto-completion in insert mode without first typing something
                  ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
                },
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
          plugin = cmp-nvim-lsp;};

        # Code editing: Auto-completion with nvim's lua api
        cmp-nvim-lua = {
          plugin = cmp-nvim-lua;};

        # Git support
        vim-fugitive = {
          plugin = vim-fugitive;};

        # Git support: show changed lines in gutter (replaces gitgutter)
        gitsigns-nvim = {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('gitsigns').setup({
              signs = {
                -- Left justified character to distinguish changed lines
                change = { hl = "GitSignsChange", text = "▎" , numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
              },
              on_attach = function(buffer)
                local options = { buffer = buffer }

                -- Motion: Next hunk
                vim.keymap.set(
                  'n',
                  ']h',
                  function()
                    if vim.wo.diff then return ']h' end
                    vim.schedule(function() package.loaded.gitsigns.next_hunk() end)
                    return '<Ignore>'
                  end,
                  {expr=true, buffer=buffer}
                )

                -- Motion: Previous hunk
                vim.keymap.set(
                  'n',
                  '[h',
                  function()
                    if vim.wo.diff then return '[h' end
                    vim.schedule(function() package.loaded.gitsigns.prev_hunk() end)
                    return '<Ignore>'
                  end,
                  {expr=true, buffer=buffer}
                )

                -- Git: stage hunk
                vim.keymap.set({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', options)

                -- Git: unstage hunk
                vim.keymap.set('n', '<leader>hu', package.loaded.gitsigns.undo_stage_hunk, options)

                -- Git: preview hunk
                vim.keymap.set('n', '<leader>hp', package.loaded.gitsigns.preview_hunk, options)

                -- Git: blame current line
                vim.keymap.set('n', '<leader>hb', function() package.loaded.gitsigns.blame_line{full=true} end, options)

                -- Git: display deleted text
                vim.keymap.set(
                  'n',
                  '<leader>hd',
                  function()
                    package.loaded.gitsigns.toggle_deleted()
                    package.loaded.gitsigns.toggle_word_diff()
                  end,
                  options
                )
              end
            })
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
            -- Search file names
            vim.keymap.set('n', '<leader>o', function() return require('telescope.builtin').find_files() end)

            -- Search file contents
            vim.keymap.set('n', '<leader>g', function() return require('telescope.builtin').live_grep() end)

            -- Search buffer names
            vim.keymap.set('n', '<leader>b', function() return require('telescope.builtin').buffers() end)

            -- Search vim help
            vim.keymap.set('n', '<leader>hh', function() return require('telescope.builtin').help_tags() end)

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
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup {
             sections = {
               lualine_a = { { 'mode', upper = true } },
               lualine_b = { { 'branch', icon = '' } },
               lualine_c = {
                  { 'filename', file_status = true, path = 1 },
                  { 'diagnostics', sources = { 'nvim_lsp' } },
                   -- { 'lsp_progress' }
               },
               lualine_x = { 'encoding', 'filetype' },
               lualine_y = { 'progress' },
               lualine_z = { 'location' },
             },
            }

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
          };
          programs.neovim = {
            viAlias = true;
            vimAlias = true;
            extraConfig = ''
              luafile ${./neovim/options.lua}
              luafile ${./neovim/keymap.lua}
            '';
            package = flake.inputs.neovim.packages."${pkgs.system}".neovim; # Remove when 0.6.2 or later is released
          };
        })
      ];
    };

    nix = {
      # Helpful for supplying remote builder options, nix copy, etc
      trustedUsers = ["root" "@wheel"];
    };

    programs = {
      bash = {
        enableCompletion = true; # auto-completion in bash
        interactiveShellInit = ''
          export HISTCONTROL=ignorespace;
        '';
      };
      git.config = {
        init.defaultBranch = "main";
        url."https://github.com/".insteadOf = ["gh:" "github:"];
      };
      ssh = {
        startAgent = lib.mkDefault true;
        agentTimeout = "1h";
      };
    };

    services = {
      # Security
      # TODO: dont start any services in preferences profile
      # gnome.gnome-keyring.enable = true; # gnome's default keyring

      # Set the desktop manager to none so that it doesn't default to xterm sometimes
      # TODO: check if this is this still needed?
      # xserver.displayManager.defaultSession = "none+xmonad";
    };
  };
}
