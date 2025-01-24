local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  lazy = false,
  dependencies = {
    "echasnovski/mini.icons",
  },
}

function M.config()
  local which_key = require "which-key"
  which_key.setup {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = false,
        g = false,
      },
    },
    win = {
      -- title_pos = "bottom",
      border = "rounded",
      no_overlap = false,
      padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      title = false,
      title_pos = "center",
      zindex = 1000,
    },
    -- filter = function(mapping)
    --   -- example to exclude mappings without a description
    --   -- return mapping.desc and mapping.desc ~= ""
    --   return true
    -- end,
    show_help = false,
    show_keys = false,
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  }

  -- local mappings = {
  --   q = { "<cmd>confirm q<CR>", "Quit" },
  --   -- h = { "<cmd>nohlsearch<CR>", "NOHL" },
  --   [";"] = { "<cmd>tabnew | terminal<CR>", "Term" },
  --   v = { "<cmd>vsplit<CR>", "Split" },
  --   b = { name = "Buffers" },
  --   d = { name = "Debug" },
  --   f = { name = "Find" },
  --   g = { name = "Git" },
  --   l = { name = "LSP" },
  --   p = { name = "Plugins" },
  --   t = { name = "Test" },
  --   a = {
  --     name = "Tab",
  --     n = { "<cmd>$tabnew<cr>", "New Empty Tab" },
  --     N = { "<cmd>tabnew %<cr>", "New Tab" },
  --     o = { "<cmd>tabonly<cr>", "Only" },
  --     h = { "<cmd>-tabmove<cr>", "Move Left" },
  --     l = { "<cmd>+tabmove<cr>", "Move Right" },
  --   },
  --   T = { name = "Treesitter" },
  -- }

  local mappings = {
    { "<leader>q", "<cmd>confirm q<CR>", group = "Quit" },
    -- ["<leader>;"] = { "<cmd>tabnew | terminal<CR>", group = "Term" },
    { "<leader>v", "<cmd>vsplit<CR>", group = "Split" },
    { "<leader>b", group = "Buffers" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>p", group = "Plugins" },
    { "<leader>t", group = "Test" },
    -- { "<leader>a",
    --   name = "<leader>Tab",
    --   n"<leader>, "<cmd>$tabnew<cr>", "New Empty Tab" },
    --   N"<leader>, "<cmd>tabnew %<cr>", "New Tab" },
    --   o"<leader>, "<cmd>tabonly<cr>", "Only" },
    --   h"<leader>, "<cmd>-tabmove<cr>", "Move Left" },
    --   l"<leader>, "<cmd>+tabmove<cr>", "Move Right" },
    -- },
    { "<leader>T", group = "Treesitter" },
  }

  local opts = {
    mode = { "n" }, -- NORMAL mode
    prefix = "<leader>",
  }

  which_key.add(mappings, opts)
  -- which_key.register(mappings, opts)
end

return M
