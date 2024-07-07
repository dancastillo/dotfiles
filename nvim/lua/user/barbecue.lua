-- https://github.com/utilyre/barbecue.nvim
local M = {
  "utilyre/barbecue.nvim",
  -- name = "barbecue",
  -- version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons", -- optional dependency
  },
}

function M.config()
  require("barbecue").setup {
    icons = require("user.icons").kind,
    lsp = {
      auto_attach = true,
    },
    click = true,
    separator = " " .. require("user.icons").ui.ChevronRight .. " ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    show_modified = true,
  }
end

return M
