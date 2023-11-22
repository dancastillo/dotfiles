-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--vim.keymap.set("n", "<C-Space>", "<cmd>WhichKey \\<space><cr>", { noremap = true, silent = true })

vim.opt.relativenumber = true

vim.keymap.set('n', '<space>f', function()
	vim.lsp.buf.format { async = true }
end, { noremap = true, silent = true })
-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true


vim.opt.cursorline = true -- highlight the current line

vim.opt.shiftwidth = 2 -- size of an indents
vim.opt.tabstop = 2 -- number of spaces tabs count
vim.opt.expandtab = true

-- do not create swap filetype
vim.opt.swapfile = false
