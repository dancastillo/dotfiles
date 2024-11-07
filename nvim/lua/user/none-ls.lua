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
  local helpers = require "null-ls.helpers"
  local utils = require "null-ls.utils"
  local methods = require "null-ls.methods"
  local FORMATTING = methods.internal.FORMATTING
  local formatter = null_ls.formatter
  local cmd_resolver = require "null-ls.helpers.command_resolver"
  local DIAGNOSTICS = methods.internal.DIAGNOSTICS

  local deno_filetypes = {
    -- "javascript",
    "typescript",
    -- "typescriptreact",
    -- "javascriptreact",
  }
  local deno_lint = helpers.make_builtin {
    name = "deno_lint",
    meta = {
      url = "https://github.com/denoland/deno_lint",
      description = "Blazing fast linter for JavaScript and TypeScript written in Rust",
    },
    method = DIAGNOSTICS,
    filetypes = deno_filetypes,
    generator_opts = {
      command = "deno",
      args = { "lint", "--json", "$FILENAME" },
      format = "json",
      to_stdin = false,
      check_exit_code = function(c)
        return c <= 1
      end,
      cwd = helpers.cache.by_bufnr(function(params)
        return utils.root_pattern("deno.json", "deno.jsonc", "package.json", ".git")(params.bufname)
      end),
      on_output = function(params)
        local diags = {}

        for _, d in ipairs(params.output.errors) do
          table.insert(diags, {
            row = 0,
            col = 1,
            message = d.message,
            severity = 1,
          })
        end

        for _, d in ipairs(params.output.diagnostics) do
          local message = d.message
          if type(d.hint) == "string" then
            message = message .. "\n" .. d.hint
          end

          table.insert(diags, {
            row = d.range.start.line,
            col = d.range.start.col + 1,
            end_row = d.range["end"].line,
            end_col = d.range["end"].col + 1,
            code = d.code,
            message = message,
            severity = 2,
          })
        end
        return diags
      end,
    },
    factory = helpers.generator_factory,
  }

  local deno_fmt_extensions = {
    -- javascript = "js",
    -- javascriptreact = "jsx",
    -- json = "json",
    -- jsonc = "jsonc",
    -- markdown = "md",
    typescript = "ts",
    -- typescriptreact = "tsx",
  }
  local deno_fmt = helpers.make_builtin {
    name = "deno_fmt",
    meta = {
      url = "https://deno.land/manual/tools/formatter",
      description = "Use [Deno](https://deno.land/) to format TypeScript, JavaScript/JSON and markdown.",
      notes = {
        "`deno fmt` supports formatting JS/X, TS/X, JSON and markdown. If you only want deno to format a subset of these filetypes you can overwrite these with `.with({filetypes={}}`)",
      },
      usage = [[
local sources = {
    null_ls.builtins.formatting.deno_fmt, -- will use the source for all supported file types
    null_ls.builtins.formatting.deno_fmt.with({
		filetypes = { "markdown" }, -- only runs `deno fmt` for markdown
    }),
}]],
    },
    method = FORMATTING,
    filetypes = deno_filetypes,
    generator_opts = {
      command = "deno",
      args = function(params)
        return { "fmt", "-", "--ext", deno_fmt_extensions[params.ft] }
      end,
      to_stdin = true,
    },
    factory = helpers.formatter_factory,
  }

  local standardjs = helpers.make_builtin {
    name = "standardjs",
    meta = {
      url = "https://standardjs.com/",
      description = "JavaScript Standard Style, a no-configuration automatic code formatter that just works.",
    },
    method = FORMATTING,
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

  -- Check if the project is a deno project
  local lspconfig = require "lspconfig"
  local function is_deno_project(filename)
    local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename)
    return denoRootDir ~= nil
  end

  -- print(is_deno_project(vim.api.nvim_buf_get_name(0)))
  -- print(is_deno_project(vim.api.nvim_buf_get_name(0)) and deno_fmt or nil)
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
        -- extra_args = {
        --   "--no-semi",
        --   "--single-quote",
        --   "--jsx-single-quote",
        --   "--trailing-comma=none",
        -- },
        only_local = "node_modules/.bin",
      },
      null_ls.builtins.formatting.stylua.with {
        filetypes = {
          "lua",
        },
        args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
      },
      -- null_ls.builtins.diagnostics.stylelint.with {
      --   filetypes = {
      --     "css",
      --     "scss",
      --   },
      -- },
      formatting.stylua,
      -- formatting.prettier,
      -- formatting.prettier.with {
      --   filetypes = { "javascript" },
      --   extra_filetypes = { "toml" },
      --   extra_args = {
      --     "--no-semi",
      --     "--single-quote",
      --     "--jsx-single-quote",
      --     "--trailing-comma=none",
      --   },
      -- },
      -- null_ls.builtins.diagnostics.eslint,
      -- null_ls.builtins.diagnostics.standardjs,
      null_ls.builtins.completion.spell,
      is_deno_project(vim.api.nvim_buf_get_name(0)) and deno_fmt or nil,
      is_deno_project(vim.api.nvim_buf_get_name(0)) and deno_lint or nil,
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
