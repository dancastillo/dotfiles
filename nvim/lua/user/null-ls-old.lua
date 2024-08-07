local null_ls = require "null-ls"
local lSsources = {
  null_ls.builtins.formatting.prettier.with {
    filetypes = {
      "javascript",
      "typescript",
      "css",
      "scss",
      "html",
      "json",
      "yaml",
      "markdown",
      "graphql",
      "md",
      "txt",
      "graphql",
    },
    only_local = "node_modules/.bin",
  },
  null_ls.builtins.formatting.stylua.with {
    filetypes = {
      "lua",
    },
    args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
  },
  null_ls.builtins.diagnostics.stylelint.with {
    filetypes = {
      "css",
      "scss",
    },
  },
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup {
  sources = lSsources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format {
            bufnr = bufnr,
            filter = function(_client)
              return _client.name == "null-ls"
            end,
          }
        end,
      })
    end
  end,
}
