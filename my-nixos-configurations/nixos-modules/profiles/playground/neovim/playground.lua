-- require('lspconfig').hls.setup({})

--require('gitsigns').setup({
--  signs = {
--    -- Left justified character to distinguish changed lines
--    change = { hl = "GitSignsChange", text = "▎" , numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
--  },
--  on_attach = function(buffer)
--    local options = { buffer = buffer }

--    -- Motion: Next hunk
--    vim.keymap.set(
--      'n',
--      ']h',
--      function()
--        if vim.wo.diff then return ']h' end
--        vim.schedule(function() package.loaded.gitsigns.next_hunk() end)
--        return '<Ignore>'
--      end,
--      {expr=true, buffer=buffer}
--    )

--    -- Motion: Previous hunk
--    vim.keymap.set(
--      'n',
--      '[h',
--      function()
--        if vim.wo.diff then return '[h' end
--        vim.schedule(function() package.loaded.gitsigns.prev_hunk() end)
--        return '<Ignore>'
--      end,
--      {expr=true, buffer=buffer}
--    )

--    -- Git: stage hunk
--    -- vim.keymap.del({'n', 'v'}, '<leader>hs')
--    -- vim.keymap.del({'v'}, '<leader>hs')
--    -- vim.keymap.set({'n'}, '<leader>hs', '<cmd>gitsigns stage_hunk<cr>', options)
--    -- vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ line('v'), line('.') }) end, options)

--    -- Git: unstage hunk
--    vim.keymap.set('n', '<leader>hu', package.loaded.gitsigns.undo_stage_hunk, options)

--    -- Git: preview hunk
--    vim.keymap.set('n', '<leader>hp', package.loaded.gitsigns.preview_hunk, options)

--    -- Git: blame current line
--    vim.keymap.set('n', '<leader>hb', function() package.loaded.gitsigns.blame_line{full=true} end, options)

--    -- Git: display deleted text
--    vim.keymap.set(
--      'n',
--      '<leader>hd',
--      function()
--        package.loaded.gitsigns.toggle_deleted()
--        package.loaded.gitsigns.toggle_word_diff()
--      end,
--      options
--    )
--  end
--})

---- vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ vim.inspect(vim.api.nvim_buf_get_mark(0, '<')), vim.inspect(vim.api.nvim_buf_get_mark(0, '>')) }) end)
---- vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ vim.api.nvim_buf_get_mark(0, '<')[1], vim.api.nvim_buf_get_mark(0, '>')[1] }) end)
--vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ vim.fn.getpos('v')[2], vim.fn.getcurpos()[2] }) end)
--print(vim.inspect({ vim.fn.getpos('v'), vim.fn.getcurpos() }))
---- print(vim.api.nvim_buf_get_mark(0, '<')[1])
---- print(vim.api.nvim_buf_get_mark(0, '<')[2])
---- print(vim.inspect(vim.api.nvim_buf_get_mark(0, '<')[0]))
---- vim.keymap.set({'v'}, '<leader>hs', package.loaded.gitsigns.stage_hunk)

---- vim.api.lines
---- vim.keymap.del({'n'}, '<leader>hs')
---- vim.keymap.set({'v'}, '<leader>hs', '<cmd>\'<,\'>gitsigns stage_hunk<cr>')
----
--vim.keymap.set({'n'}, '<leader>hr', '<cmd>gitsigns reset_hunk<cr>', options)

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
