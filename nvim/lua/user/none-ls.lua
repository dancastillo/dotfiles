-- lua/plugins/none-ls.lua
local M = {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
}

function M.config()
  local null_ls = require("null-ls")
  local helpers = require("null-ls.helpers")
  local methods = require("null-ls.methods")
  local FORMATTING = methods.internal.FORMATTING

  ----------------------------------------------------------------------
  -- Hard-coded prettier (no prefer_local). We resolve command explicitly.
  -- If local node_modules/.bin/prettier exists, we use it; else global.
  ----------------------------------------------------------------------
  local function find_prettier()
    local cwd = vim.fn.getcwd()
    local local_cmd = cwd .. "/node_modules/.bin/prettier"
    if vim.loop.fs_stat(local_cmd) then
      return local_cmd
    end
    -- fallback: look on PATH
    if vim.fn.executable("prettier") == 1 then
      return "prettier"
    end
    return nil
  end

  local PRETTIER_CMD = find_prettier()
  if not PRETTIER_CMD then
    vim.schedule(function()
      vim.notify("[null-ls] No prettier found (install locally or globally)", vim.log.levels.ERROR)
    end)
  end

  local prettier_builtin = helpers.make_builtin({
    name = "hard_prettier",
    meta = {
      url = "https://prettier.io",
      description = "Hard-coded prettier formatter for debugging",
    },
    method = FORMATTING,
    filetypes = {
      "javascript","typescript",
      "javascriptreact","typescriptreact",
      "json","jsonc",
      "css","scss","less",
      "html","yaml","markdown","md","graphql",
    },
    generator_opts = {
      command = PRETTIER_CMD or "prettier", -- still attempt; will show error if missing
      to_stdin = true,
      args = { "--stdin-filepath", "$FILENAME" },
      timeout = 8000,
      on_output = function(params)
        if params.err then
          vim.schedule(function()
            vim.notify("[hard_prettier] stderr: " .. params.err, vim.log.levels.ERROR)
          end)
        end
      end,
    },
    factory = helpers.formatter_factory,
  })

  local augroup = vim.api.nvim_create_augroup("HardFormatOnSave", {})

  null_ls.setup({
    debug = true,
    log_level = "trace",
    sources = { prettier_builtin },
    on_attach = function(client, bufnr)
      if not client.supports_method("textDocument/formatting") then
        vim.notify("[null-ls] client lacks formatting capability", vim.log.levels.ERROR)
        return
      end
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          print("[FMT] BufWritePre (buf=" .. bufnr .. ")")
          local ok, err = pcall(function()
            vim.lsp.buf.format({
              bufnr = bufnr,
              async = false,      -- block so we see completion or failure
              timeout_ms = 8000,
              filter = function(c) return c.name == "null-ls" end,
            })
          end)
          if not ok then
            vim.notify("[FMT] format threw: " .. tostring(err), vim.log.levels.ERROR)
          else
            print("[FMT] format done (buf=" .. bufnr .. ")")
          end
        end,
      })
    end,
  })

  vim.api.nvim_create_user_command("FormatNow", function()
    print("[FMT] Manual start")
    vim.lsp.buf.format({
      bufnr = 0,
      async = false,
      timeout_ms = 8000,
      filter = function(c) return c.name == "null-ls" end,
    })
    print("[FMT] Manual end")
  end, {})
end

return M
