require('gitsigns').setup({
  signs = {
    -- Left justified character to distinguish changed lines
    change = { hl = "GitSignsChange", text = "▎" , numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
  },
  on_attach = function(buffer)
    local options = function(additional_options)
      local final_options = {
        buffer = buffer,
      }
      for key,value in pairs(additional_options or {}) do final_options[key] = value end
      return final_options
    end


    -- Motion: Next hunk
    vim.keymap.set(
      'n',
      ']h',
      function()
        if vim.wo.diff then return ']h' end
        vim.schedule(function() package.loaded.gitsigns.next_hunk() end)
        return '<Ignore>'
      end,
      {expr=true, buffer=buffer, desc="Gitsigns: next hunk"}
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
      {expr=true, buffer=buffer, desc="Gitsigns: previous hunk"}
    )

    -- Gitsigns: stage hunk
    vim.keymap.set({'n'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', options({ desc = "Gitsigns: stage hunk" }))

    -- Gitsigns: stage partial hunk
    vim.keymap.set({'v'}, '<leader>hs', function() package.loaded.gitsigns.stage_hunk({ vim.fn.getpos('v')[2], vim.fn.getcurpos()[2] }) end, options({ desc = "Gitsigns: stage partial hunk" }))

    -- Gitsigns: undo stage hunk
    -- See https://github.com/lewis6991/gitsigns.nvim/issues/510
    vim.keymap.set('n', '<leader>hu', package.loaded.gitsigns.undo_stage_hunk, options({ desc = "Gitsigns: undo stage hunk" }))

    -- Gitsigns: preview hunk
    vim.keymap.set('n', '<leader>hp', package.loaded.gitsigns.preview_hunk, options({ desc = "Gitsigns: preview hunk" }))

    -- Gitsigns: blame current line
    vim.keymap.set('n', '<leader>hb', function() package.loaded.gitsigns.blame_line{full=true} end, options({ desc = "Gitsigns: blame line" }))

    -- Gitsigns: display deleted text
    -- https://github.com/lewis6991/gitsigns.nvim/issues/506
    vim.keymap.set(
      'n',
      '<leader>hd',
      function()
        local show_deleted = package.loaded.gitsigns.toggle_deleted()
        package.loaded.gitsigns.toggle_word_diff(show_deleted)
      end,
      options({ desc = "Gitsigns: display deleted text" })
    )
  end
})
