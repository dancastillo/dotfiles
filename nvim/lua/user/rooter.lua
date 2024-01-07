local M = {
  "notjedi/nvim-rooter.lua",
}

function M.config()
  require("nvim-rooter").setup{
    rooter_patterns = { ".git", ".hg", ".svn" },
    trigger_patterns = { "*" },
    manual = false,
  }
end

return M
