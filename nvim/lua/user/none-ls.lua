local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

function M.config()
  local null_ls = require "null-ls"

  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics

  -- local helpers = require "null-ls.helpers"
  -- local cmd_resolver = require "null-ls.helpers.command_resolver"
  -- local methods = require "null-ls.methods"
  -- local FORMATTING = methods.internal.FORMATTING

  -- local standardjs = helpers.make_builtin {
  --   name = "standardjs",
  --   method = FORMATTING,
  --   filetypes = { "javascript", "javascriptreact" },
  --   generator_opts = {
  --     command = "standard",
  --     args = { "--fix" },
  --     to_stdin = true,
  --     -- dynamic_command = cmd_resolver.from_node_modules,
  --   },
  --   factory = helpers.formatter_factory,
  -- }

  null_ls.setup {
    sources = {
      -- standardjs,
      formatting.prettier.with {
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
      formatting.stylua,
      -- formatting.prettier,
      -- formatting.prettier.with {
      --   extra_filetypes = { "toml" },
      --   -- extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
      -- },
      -- null_ls.builtins.diagnostics.eslint,
      -- null_ls.builtins.diagnostics.standardjs,
      null_ls.builtins.completion.spell,
    },
    on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    end,
  }
end

return M
