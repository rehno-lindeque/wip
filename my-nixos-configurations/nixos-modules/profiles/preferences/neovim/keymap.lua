options = {
  -- Avoid miscellaneous command-line noise
  silent = true
}

-- Remap spacebar as the leader key
vim.keymap.set('', '<Space>', '<Nop>', options)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Normal mode: Save when the leader key is hit twice (i.e. spacebar)
vim.keymap.set('n', '<leader><leader>', '<cmd>w<cr>', options)

-- Normal mode: Quit via the leader key instead of :
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', options)
vim.keymap.set('n', '<leader>Q', '<cmd>q!<cr>', options)

-- Visual mode: Don't replace the yanked register when pasting in visual mode
vim.keymap.set({'v', 'x'}, 'p', '"_dP', options)
