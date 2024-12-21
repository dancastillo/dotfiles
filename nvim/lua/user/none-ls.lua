local M = {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}

function M.config()
  local null_ls = require "null-ls"

  local formatting = null_ls.builtins.formatting
  local helpers = require "null-ls.helpers"
  local methods = require "null-ls.methods"
  local FORMATTING = methods.internal.FORMATTING
  local cmd_resolver = require "null-ls.helpers.command_resolver"

  local standardjs = helpers.make_builtin {
    name = "standardjs",
    meta = {
      url = "https://standardjs.com/",
      description = "JavaScript Standard Style, a no-configuration automatic code formatter that just works.",
    },
    method = 'NULL_LS_FORMATTING',
    filetypes = { "javascript", "javascriptreact" },
    generator_opts = {
      command = "standard",
      args = { "--stdin", "--fix" },
      to_stdin = true,
      dynamic_command = cmd_resolver.from_node_modules(),
    },
    factory = helpers.formatter_factory,
  }

  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  vim.lsp.buf.format { timeout_ms = 10000 }
  null_ls.setup {
    sources = {
      standardjs,
      formatting.prettier.with {
        filetypes = {
          "javascript",
          "typescript",
          "css",
          "scss",
          "html",
          "json",
          "yaml",
          -- "markdown",
          "graphql",
          "md",
          "txt",
          "typescriptreact",
          "javascriptreact",
        },
        only_local = "node_modules/.bin",
      },
      null_ls.builtins.formatting.stylua.with {
        filetypes = {
          "lua",
        },
        args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
      },
      formatting.stylua,
      null_ls.builtins.completion.spell,
    },
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
end

return M
