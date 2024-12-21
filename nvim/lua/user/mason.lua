local M = {
  "williamboman/mason-lspconfig.nvim",
  commit = "e7b64c11035aa924f87385b72145e0ccf68a7e0a",
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
    "tsserver",
    "bashls",
    "jsonls",
    "yamlls",
    "marksman",
    "tailwindcss",
    "typescript-language-server"
  }
  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }
  require("mason-lspconfig").setup {
    ensure_installed = servers,
    automatic_installation = true,
  }
end

return M
