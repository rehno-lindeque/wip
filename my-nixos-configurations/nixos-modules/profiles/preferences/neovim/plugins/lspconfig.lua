local lspconfig = require('lspconfig')

-- Diagnostics: show details about the error under the cursor
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)

-- Diagnostics: go to the next error
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)

-- Diagnostics: go to the previous error
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

local on_attach = function(client, buffer)
  local options = { buffer = buffer }

  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, options)
end

-- local on_attach = function(client, bufnr)
--   local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
--   local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
--
--   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
--
--   -- Mappings.
--   local opts = { noremap=true, silent=true }
--   buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
--   buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
--   buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
--   buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--   buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--   buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--   buf_set_keymap('n', '<space>ws', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
--   buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--   buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
--   buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--   buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
--   buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
--   buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
--   buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
--   buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--
--   -- Set some keybinds conditional on server capabilities
--   if client.resolved_capabilities.document_formatting then
--     buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
--   elseif client.resolved_capabilities.document_range_formatting then
--     buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
--   end
-- end

local flags = {
  -- Avoid excessive refresh
  -- TODO: This will be the default in neovim 0.7+
  debounce_text_changes = 150,
}

-- Set up each language server: Nix configuration language
lspconfig.rnix.setup({
  on_attach = on_attach,
  autostart = true,
  flags = flags,
})

-- Set up each language server: Haskell programming language
lspconfig.hls.setup({
  on_attach = on_attach,
  autostart = true,
  flags = flags,
  settings = {
    haskell = {
      -- Turn off everything because HLS appears prone to crashing at the moment
      checkParents = "CheckOnSave",
      checkProject = false,
      formattingProvider = "ormolu",
      maxCompletions =  40,
      plugin = {
        alternateNumberFormat = {
          globalOn = false,
        },
        callHierarchy = {
          globalOn = false,
        },
        class = {
          globalOn = false,
        },
        eval = {
          globalOn = false,
        },
        ['ghcide-code-actions-bindings'] = {
          globalOn = false,
        },
        ['ghcide-code-actions-fill-holes'] = {
          globalOn = false,
        },
        ['ghcide-code-actions-imports-exports'] = {
          globalOn = false,
        },
        ['ghcide-code-actions-type-signatures'] = {
          globalOn = false,
        },
        ['ghcide-completions'] = {
          config = {
            autoExtendOn = false,
            snippetsOn = false,
          },
          globalOn = false,
        },
        ['ghcide-hover-and-symbols'] = {
          hoverOn = false,
          symbolsOn = false,
        },
        ['ghcide-type-lenses'] = {
          config = {
            mode = "always"
          },
          globalOn = false,
        },
        haddockComments = {
          globalOn = false,
        },
        hlint = {
          codeActionsOn = false,
          config = {
            flags = {},
          },
          diagnosticsOn = false,
        },
        importLens = {
          codeActionsOn = false,
          codeLensOn = false,
        },
        moduleName = {
          globalOn = false,
        },
        pragmas = {
          codeActionsOn = false,
          completionOn = false,
        },
        qualifyImportedNames = {
          globalOn = false,
        },
        refineImports = {
          codeActionsOn = false,
          codeLensOn = false,
        },
        retrie = {
          globalOn = false,
        },
        splice = {
          globalOn = false,
        },
      },
    },
  },
})

-- Set up each language server: Lua programming language
lspconfig.sumneko_lua.setup({
  on_attach = on_attach,
  autostart = true,
  flags = flags,
})

-- Set up each language server: Elm programming language
lspconfig.elmls.setup({
  on_attach = on_attach,
  autostart = true,
  flags = flags,
})

-- Set up each language server: Python programming language
-- TODO
-- lspconfig.pyright.setup { on_attach = on_attach, autostart = false }
-- lspconfig.python-lsp-server.setup { on_attach = on_attach, autostart = false }
-- lspconfig.pylsp.setup { on_attach = on_attach, autostart = false }

