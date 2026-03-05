local M = {
  "stevearc/oil.nvim",
  cmd = { "Oil" },
  keys = {
    { "-", "<CMD>Oil --float<CR>", desc = "Open parent directory" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}

function M.config()
  require("oil").setup {
    float = {
      max_height = 20,
      max_width = 60,
    },
  }
end

return M
