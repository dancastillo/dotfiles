local M = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      event = "VeryLazy",
    },
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      event = "VeryLazy",
    },
    {
      "windwp/nvim-ts-autotag",
      event = "VeryLazy",
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
    },
  },
}
function M.config()
  local ts_configs = require("nvim-treesitter.configs")

  ---@type TSConfig
  local opts = {
    modules = {},          -- satisfy LuaLS
    ignore_install = {},   -- satisfy LuaLS (empty list = default)

    ensure_installed = {
      "javascript", "typescript", "lua", "markdown", "markdown_inline", "bash", "vim", "html",
      -- "tsx",
    },
    sync_install = false,
    auto_install = false,

    highlight = {
      enable = true,
      disable = { "markdown" },
      additional_vim_regex_highlighting = false,
    },

    indent = {
      enable = true,
      disable = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    },

    matchup = { enable = true },
    -- autotag = { enable = true },

    -- context_commentstring = {
    --   enable = true,
    --   enable_autocmd = false,
    -- },

    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["at"] = "@class.outer",
          ["it"] = "@class.inner",
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ai"] = "@conditional.outer",
          ["ii"] = "@conditional.inner",
          ["a/"] = "@comment.outer",
          ["i/"] = "@comment.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["as"] = "@statement.outer",
          ["is"] = "@scopename.inner",
          ["aA"] = "@attribute.outer",
          ["iA"] = "@attribute.inner",
          ["aF"] = "@frame.outer",
          ["iF"] = "@frame.inner",
        },
      },
    },
  }

  ts_configs.setup(opts)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    callback = function()
      -- vim.opt_local.formatoptions:remove({ "t" })
      -- vim.opt_local.formatoptions:append({ "o", "r", "c" })
      vim.opt_local.autoindent = true
      vim.opt_local.smartindent = true
    end,
  })
end

return M
