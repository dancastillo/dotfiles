local M = {
  "lukas-reineke/indent-blankline.nvim",
    -- main = "ibl",
    -- ---@module "ibl"
    -- ---@type ibl.config
  -- opts = {},
  event = "VeryLazy",
  -- commit = "9637670896b68805430e2f72cf5d16be5b97a22a",
}

function M.config()
  local icons = require "user.icons"

  require("ibl").setup {
    exclude = {
      filetypes = {
        "help",
        "startify",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      },
      buftypes = { "terminal", "nofile" },
    },
    scope = { enabled = false },
    indent = { char = icons.ui.LineMiddle },
    -- char = icons.ui.LineMiddle,
    -- context_char = icons.ui.LineMiddle,
    --
    -- show_trailing_blankline_indent = false,
    -- remove_blankline_trail = true,

    -- show_first_indent_level = true,
    -- show_current_context = true,
    -- use_treesitter = true,
  }

  -- indent = { char = icons.ui.LineMiddle },
  -- whitespace = {
  --   remove_blankline_trail = true,
  -- },
  --
  -- exclude = {
  --   filetypes = {
  --     "help",
  --     "startify",
  --     "dashboard",
  --     "lazy",
  --     "neogitstatus",
  --     "NvimTree",
  --     "Trouble",
  --     "text",
  --   },
  --   buftypes = { "terminal", "nofile" },
  -- },
  -- scope = { enabled = false },
end

return M
