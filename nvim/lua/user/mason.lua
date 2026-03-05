local M = {
  "williamboman/mason-lspconfig.nvim",
  event = "VeryLazy",
  dependencies = {
    "williamboman/mason.nvim",
    "nvim-lua/plenary.nvim",
  },
}

function M.config()
  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "ts_ls",
    "eslint",
    "bashls",
    "jsonls",
    "yamlls",
    "marksman",
    "tailwindcss"
  }
  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }
  require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_installation = true,
    automatic_enable = false,
  }
end

return M
