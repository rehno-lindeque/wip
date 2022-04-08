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
    vim.keymap.set({'n'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', options)

    -- Git: stage partial hunk
    vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ vim.fn.getpos('v')[2], vim.fn.getcurpos()[2] }) end)

    -- Git: undo stage hunk
    -- See https://github.com/lewis6991/gitsigns.nvim/issues/510
    vim.keymap.set('n', '<leader>hu', package.loaded.gitsigns.undo_stage_hunk, options)

    -- Git: preview hunk
    vim.keymap.set('n', '<leader>hp', package.loaded.gitsigns.preview_hunk, options)

    -- Git: blame current line
    vim.keymap.set('n', '<leader>hb', function() package.loaded.gitsigns.blame_line{full=true} end, options)

    -- Git: display deleted text
    -- https://github.com/lewis6991/gitsigns.nvim/issues/506
    vim.keymap.set(
      'n',
      '<leader>hd',
      function()
        local show_deleted = package.loaded.gitsigns.toggle_deleted()
        package.loaded.gitsigns.toggle_word_diff(show_deleted)
      end,
      options
    )
  end
})
