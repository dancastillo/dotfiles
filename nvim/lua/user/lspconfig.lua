local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neodev.nvim" },
  },
}

local function lsp_keymaps(bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
  end
  map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")
  map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")
  map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
  map("n", "gI", vim.lsp.buf.implementation, "LSP: Implementation")
  map("n", "gr", vim.lsp.buf.references, "LSP: References")
  map("n", "gl", vim.diagnostic.open_float, "Diagnostics: Float")
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)

  -- Hard block all diagnostics from Deno LSP (covers push & pull diagnostics).
  if client.name == "denols" then
    client.handlers["textDocument/publishDiagnostics"] = function() end
    client.handlers["textDocument/diagnostic"] = function() end
    client.handlers["workspace/diagnostic/refresh"] = function() end
  end

  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

M.toggle_inlay_hints = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end

function M.common_capabilities()
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok then
    return cmp.default_capabilities()
  end
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  capabilities.workspace.workspaceFolders = false
  capabilities.workspace.didChangeConfiguration.dynamicRegistration = true
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
  return capabilities
end

function M.config()
  local wk = require("which-key")
  wk.add({
    { "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" } },
    {
      "<leader>lf",
      function()
        vim.lsp.buf.format({
          async = true,
          filter = function(c) return c.name ~= "typescript-tools" end,
        })
      end,
      desc = "Format",
    },
    { "<leader>lh", M.toggle_inlay_hints, { desc = "Toggle Inlay Hints" } },
    { "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" } },
    -- { "<leader>lj", vim.diagnostic.goto_next, { desc = "Next Diagnostic" } },
    -- { "<leader>lk", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" } },
    -- Next diagnostic
    { "<leader>lj", function()
        vim.diagnostic.jump { count = 1, float = true }
      end,
      desc = "Next Diagnostic"
    },

    -- Previous diagnostic
    { "<leader>lk", function()
        vim.diagnostic.jump { count = -1, float = true }
      end,
      desc = "Prev Diagnostic"
    },

    { "<leader>ll", vim.lsp.codelens.run, { desc = "CodeLens Action" } },
    { "<leader>lq", vim.diagnostic.setloclist, { desc = "Diagnostics to Loclist" } },
    { "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" } },
  })

  -- Diagnostics UI
  local icons = require("user.icons")
  vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      -- source = "always",
      source = true,
      header = "",
      prefix = "",
    },
    signs = {
      active = true,
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warning,
        [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO]  = icons.diagnostics.Information,
      },
    },
  })

  -- Rounded borders
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  require("lspconfig.ui.windows").default_options.border = "rounded"

  require("neodev").setup({})

  local lspconfig = require("lspconfig")
  local util = require("lspconfig.util")

  -- Helper: treat files with deno.json/deno.jsonc as Deno projects
  local function is_deno_project(fname)
    return util.root_pattern("deno.json", "deno.jsonc")(fname)
  end

  -- TS/JS server root: NEVER attach in Deno projects
  local function ts_root_dir(fname)
    if is_deno_project(fname) then
      return nil
    end
    return util.root_pattern("package.json", "tsconfig.json", ".git")(fname)
  end

  -- Denols: disabled by default; also kill it if something else forces it to attach.
  lspconfig.denols.setup({
    on_attach = M.on_attach,
    capabilities = M.common_capabilities(),
    autostart = false,                                -- do NOT start automatically
    single_file_support = false,
    root_dir = util.root_pattern("deno.json", "deno.jsonc"),
    settings = {
      deno = {
        enable = true,
        lint = true,                                  -- enable server-side, but we suppress diagnostics client-side
        suggest = { imports = { autoDiscover = true } },
      },
    },
  })

  -- Safety net: if denols is spawned by anything, stop it immediately.
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "denols" then
        -- clear any diagnostics it might have set already, then stop the client
        pcall(function()
          local ns = vim.lsp.diagnostic and vim.lsp.diagnostic.get_namespace
            and vim.lsp.diagnostic.get_namespace(client.id)
          if ns then pcall(vim.diagnostic.reset, ns, args.buf) end
        end)
        client.stop(true)
      end
    end,
  })

  -- Normal servers
  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "ts_ls",      -- typescript-language-server
    "pyright",
    "bashls",
    "jsonls",
    "yamlls",
    "marksman",
    "tailwindcss",
  }

  for _, server in ipairs(servers) do
    local opts = {
      on_attach = M.on_attach,
      capabilities = M.common_capabilities(),
      root_dir = util.root_pattern(".git"),
    }

    if server == "ts_ls" then
      opts.single_file_support = false
      opts.root_dir = ts_root_dir
      opts.settings = {
        javascript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
          },
        },
        typescript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
          },
        },
      }
    end

    local ok, settings = pcall(require, "user.lspsettings." .. server)
    if ok then
      opts = vim.tbl_deep_extend("force", settings, opts)
    end

    lspconfig[server].setup(opts)
  end
end

return M
