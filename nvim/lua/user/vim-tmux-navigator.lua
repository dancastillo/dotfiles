local M = {
  "christoomey/vim-tmux-navigator",
}

function M.config()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  keymap("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
  keymap("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", opts)
  keymap("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", opts)
  keymap("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", opts)
end

return M
