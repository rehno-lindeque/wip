-- See :help options for information

-- Always copy & paste between vim and the system clipboard
vim.opt.clipboard = 'unnamedplus'

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

-- Support 24bit colors in the terminal (widely supported by most terminals)
vim.opt.termguicolors = true

-- Persist & restore undo history when writing / opening a file
vim.opt.undofile = true

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

-- Maintain a couple of extra lines above/below cursor during scroll
vim.opt.scrolloff = 8

-- Display a single status for the focussed window instead of showing one in every window
vim.opt.laststatus = 3
