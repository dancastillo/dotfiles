local opts = { noremap = false, silent = true }

local keymap = vim.keymap.set

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
keymap('n', 'gl', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
keymap('n', 'gk', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- Navigation Renmap
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)

-- Navigate Buffers
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)

-- Move text up and down
keymap('n', '<A-j>', ':m .+1<CR>==', opts)
keymap('n', '<A-k>', ':m .-2<CR>==', opts)

-- Paste Remap
keymap("v", "p", '"_dP', opts)

-- Quit buffer
vim.api.nvim_set_keymap('n', '<leader>q', ':bdelete<CR>', { noremap = true, silent = true })

keymap('v', 'J', ":m '>+1<CR>gv=gv", opts)
keymap('v', 'K', ":m '<-2<CR>gv=gv", opts)

-- Page up and down stay in middle
keymap('n', '<C-d>', '<C-d>zz')
keymap('n', '<C-u>', '<C-u>zz')

-- Search terms stay in middle
keymap('n', 'n', 'nzzzv')
keymap('n', 'N', 'Nzzzv')

-- Replace word that was one
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

