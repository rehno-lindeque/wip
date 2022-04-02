-- See :help options for information

-- Copy & paste between vim and the system clipboard
-- vim.opt.clipboard = 'unnamedplus' -- TODO: this does not work well over ssh

-- More space in the command-line for displaying messages
vim.opt.cmdheight = 2

-- Set the file encoding to utf-8 whenever a file is saved
vim.opt.fileencoding = "utf-8"

-- Ignore case in search patterns
vim.opt.ignorecase = true                       

-- DON'T ignore case in search pattern with a uppercase character
vim.opt.smartcase = true

-- Enable mouse interactions in all modes (e.g. drag status line, separatators, switch between splits, etc)
vim.opt.mouse = "a"                             

-- Limit the pop up menu height
vim.opt.pumheight = 20

-- Horizontal splits open below the current window
vim.opt.splitbelow = true                       

-- Vertical splits open to the right of current window
vim.opt.splitright = true                       

-- Don't create a swapfile
-- vim.opt.swapfile = false                        

-- Support 24bit colors in the terminal (widely supported by most terminals)
vim.opt.termguicolors = true

-- Persist & restore undo history when writing / opening a file
vim.opt.undofile = true                         

-- Faster completion (4000ms default, it also interacts with vim.opt.swapfile)
-- vim.opt.updatetime = 300

-- If a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
-- vim.opt.writebackup = false                     

-- Convert tabs to spaces
vim.opt.expandtab = true

-- Insert 2 spaces per tab and indent
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- Highlight the entire line
vim.opt.cursorline = true

-- Show line numbers
vim.opt.number = true

-- Always show the sign column, otherwise it would shift the text each time
-- vim.opt.signcolumn = "yes"                      

-- Maintain a couple of extra lines above/below cursor during scroll
vim.opt.scrolloff = 8

-- Unaltered defaults
-- vim.opt.autoindent = true
-- vim.opt.background = 'dark'
-- vim.opt.backup = false
-- vim.opt.conceallevel = 0
-- vim.opt.hlsearch = true
-- vim.opt.numberwidth = 4
-- vim.opt.relativenumber = false
-- vim.opt.ruler = true
-- vim.opt.showtabline = 1
-- vim.opt.sidescrolloff = 0
-- vim.opt.smartindent = false
-- vim.opt.timeoutlen = 1000
-- vim.opt.wrap = true
