local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neodev.nvim" },
  },
}

local function goto_definition()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx)
    if err or not result or (type(result) == "table" and vim.tbl_isempty(result)) then
      return
    end
    local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
    local enc = (client and client.offset_encoding) or "utf-16"
    local target = (type(result) == "table" and result[1]) or result
    vim.lsp.util.jump_to_location(target, enc, true) -- reuse current window
    vim.cmd("normal! zvzz") -- open folds, center cursor
  end)
end

local function lsp_keymaps(bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
  end
  -- map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")
  -- map("n", "gd", vim.lsp.buf.definition, "LSP: Definition")
  -- map("n", "K",  vim.lsp.buf.hover, "LSP: Hover")
  -- map("n", "gI", vim.lsp.buf.implementation, "LSP: Implementation")
  -- map("n", "gr", vim.lsp.buf.references, "LSP: References")
  -- map("n", "gl", vim.diagnostic.open_float, "Diagnostics: Float")

   -- Jumps
  map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration")
  map("n", "gd", goto_definition, "LSP: Definition (jump)")
  map("n", "gI", vim.lsp.buf.implementation, "LSP: Implementation")
  map("n", "gr", vim.lsp.buf.references, "LSP: References")

  -- Info / actions
  map("n", "K",  vim.lsp.buf.hover, "LSP: Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")

  -- Diagnostics (Neovim 0.11+ safe)
  map("n", "gl", function() vim.diagnostic.open_float({ border = "rounded", focusable = false }) end, "Diagnostics: Float")
  map("n", "[d", function() vim.diagnostic.goto_prev({ wrap = true }) end, "Diagnostics: Prev")
  map("n", "]d", function() vim.diagnostic.goto_next({ wrap = true }) end, "Diagnostics: Next")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics: To Loclist")
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)

  -- Block Deno diagnostics if it ever attaches (we also stop it below).
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
  if ok then return cmp.default_capabilities() end
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
  require("neodev").setup({})

  -- which-key: use the v3 API shape (desc as a key; consistent list items)
  local wk = require("which-key")
  wk.add({
    { "<leader>la", vim.lsp.buf.code_action,                   desc = "Code Action",          mode = "n" },
    { "<leader>lf", function()
        vim.lsp.buf.format({ async = true, filter = function(c) return c.name ~= "typescript-tools" end })
      end,                                                    desc = "Format",               mode = "n" },
    { "<leader>lh", M.toggle_inlay_hints,                      desc = "Toggle Inlay Hints",   mode = "n" },
    { "<leader>li", "<cmd>LspInfo<cr>",                        desc = "LSP Info",             mode = "n" },
    { "<leader>lj", function() vim.diagnostic.jump { count =  1,  float = true } end, desc = "Next Diagnostic", mode = "n" },
    { "<leader>lk", function() vim.diagnostic.jump { count = -1,  float = true } end, desc = "Prev Diagnostic", mode = "n" },
    { "<leader>ll", vim.lsp.codelens.run,                      desc = "CodeLens Action",      mode = "n" },
    { "<leader>lq", vim.diagnostic.setloclist,                 desc = "Diagnostics → Loclist",mode = "n" },
    { "<leader>lr", vim.lsp.buf.rename,                        desc = "Rename",               mode = "n" },
  })

  -- Diagnostics UI (Neovim 0.11+): remove invalid "active" key, keep per-severity text
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
      source = true,
      header = "",
      prefix = "",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warning,
        [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO]  = icons.diagnostics.Information,
      },
    },
  })

  -- Rounded borders
  vim.lsp.handlers["textDocument/hover"]         = vim.lsp.with(vim.lsp.handlers.hover,         { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
  require("lspconfig.ui.windows").default_options.border = "rounded"

  local lspconfig = require("lspconfig")
  local util      = require("lspconfig.util")

  -- Deno detection
  local function is_deno_project(fname)
    return util.root_pattern("deno.json", "deno.jsonc")(fname)
  end

  -- In a monorepo, keep TS roots tight to project/package (not git root)
  local function ts_root_dir(fname)
    if is_deno_project(fname) then return nil end
    return util.root_pattern("tsconfig.json", "package.json")(fname)
           or util.find_node_modules_ancestor(fname)
  end

  -- Keep denols disabled by default (and stop it if spawned)
  lspconfig.denols.setup({
    on_attach = M.on_attach,
    capabilities = M.common_capabilities(),
    autostart = false,
    single_file_support = false,
    root_dir = util.root_pattern("deno.json", "deno.jsonc"),
    settings = {
      deno = {
        enable = true,
        lint = true,
        suggest = { imports = { autoDiscover = true } },
      },
    },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == "denols" then
        pcall(vim.diagnostic.reset, nil, args.buf) -- reset all namespaces for this buffer
        client.stop(true)
      end
    end,
  })

  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "ts_ls",      -- typescript-language-server (new name)
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
      -- Use lightweight roots by default in a monorepo to avoid scanning the world
      root_dir = util.root_pattern("package.json", ".git"),
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
            -- includeInlayParameterNameHints = "all",
            -- includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            -- includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
          },
        },
        typescript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            -- includeInlayParameterNameHints = "all",
            -- includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            -- includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false,
          },
          -- Better perf & correctness in monorepos
          tsserver = {
            maxTsServerMemory = 4096,
          },
          format = { enable = false }, -- prefer prettier/eslint
        },
      }
    end

    local ok, user_settings = pcall(require, "user.lspsettings." .. server)
    if ok then
      opts = vim.tbl_deep_extend("force", opts, user_settings)
    end

    lspconfig[server].setup(opts)
  end
end

return M
