local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/neodev.nvim", lazy = true },
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
  map("n", "gl", function() vim.diagnostic.open_float({ border = "rounded" }) end, "Diagnostics: Float")
  map("n", "[d", function() vim.diagnostic.goto_prev({ wrap = true }) end, "Diagnostics: Prev")
  map("n", "]d", function() vim.diagnostic.goto_next({ wrap = true }) end, "Diagnostics: Next")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics: To Loclist")
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)

  -- Fix TypeScript server errors with outlining spans
  if client.name == "ts_ls" then
    -- Disable problematic features that cause "length < 0" errors
    client.server_capabilities.documentSymbolProvider = false

    -- Folding requests can also hit outlining spans; disable by default.
    if vim.g.ts_ls_disable_folding ~= false then
      client.server_capabilities.foldingRangeProvider = false
    end
    
    -- Override handlers to catch and suppress errors
    client.handlers["textDocument/documentSymbol"] = function(err, result, ctx, config)
      if err and err.message and err.message:match("length < 0") then
        return nil
      end
      return vim.lsp.handlers["textDocument/documentSymbol"](err, result, ctx, config)
    end

    client.handlers["textDocument/foldingRange"] = function(err, result, ctx, config)
      if err and err.message and err.message:match("length < 0") then
        return nil
      end
      return vim.lsp.handlers["textDocument/foldingRange"](err, result, ctx, config)
    end
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
        local ok, conform = pcall(require, "conform")
        if ok then
          conform.format({ async = true, lsp_fallback = true })
          return
        end
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
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
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

  local util = require("lspconfig.util")

  local function bufname(bufnr)
    return vim.api.nvim_buf_get_name(bufnr)
  end

  local function deno_root(bufnr)
    local fname = bufname(bufnr)
    if fname == "" then return nil end
    return util.root_pattern("deno.json", "deno.jsonc")(fname)
  end

  -- In a monorepo, keep TS roots tight to project/package (not git root)
  local function ts_root_dir(bufnr, on_dir)
    if vim.g.enable_denols == true and deno_root(bufnr) then
      return
    end
    local fname = bufname(bufnr)
    if fname == "" then return end
    local root = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(fname)
      or util.find_node_modules_ancestor(fname)
    if root then
      on_dir(root)
    end
  end

  local function denols_root_dir(bufnr, on_dir)
    if vim.g.enable_denols ~= true then
      return
    end
    local root = deno_root(bufnr)
    if root then
      on_dir(root)
    end
  end

  local function ts_ls_init_options()
    local init_options = {
      hostInfo = "neovim",
      -- tsserver options exposed by typescript-language-server init options.
      disableAutomaticTypingAcquisition = true,
      maxTsServerMemory = 8192,
      tsserver = {
        -- Reduce outline-based requests that can trigger tsserver span errors.
        useSyntaxServer = "never",
      },
    }

    if vim.g.ts_ls_enable_logging then
      local log_dir = vim.fn.stdpath("log") .. "/tsserver"
      vim.fn.mkdir(log_dir, "p")
      init_options.tsserver.logDirectory = log_dir
      init_options.logVerbosity = "verbose"
      init_options.tsserver.trace = "messages"
    end

    return init_options
  end

  local function ts_ls_cmd()
    local cmd = { "typescript-language-server", "--stdio" }
    local tsserver_path = vim.g.ts_ls_tsserver_path
    if type(tsserver_path) == "string" and tsserver_path ~= "" then
      table.insert(cmd, "--tsserver-path")
      table.insert(cmd, tsserver_path)
    end
    return cmd
  end

  local deno_opts = {
    on_attach = M.on_attach,
    capabilities = M.common_capabilities(),
    workspace_required = true,
    root_dir = denols_root_dir,
    settings = {
      deno = {
        enable = true,
        lint = true,
        suggest = { imports = { autoDiscover = true } },
      },
    },
  }
  vim.lsp.config("denols", deno_opts)
  if vim.g.enable_denols == true then
    vim.lsp.enable("denols")
  end

  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "ts_ls",      -- typescript-language-server (new name)
    "eslint",
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
      root_markers = { "package.json", ".git" },
    }

    if server == "ts_ls" then
      local caps = opts.capabilities or M.common_capabilities()
      if caps.textDocument then
        -- Avoid requesting features that rely on outlining spans.
        caps.textDocument.documentSymbol = nil
        caps.textDocument.foldingRange = nil
      end
      opts.capabilities = caps

      opts.cmd = ts_ls_cmd()
      opts.workspace_required = true
      opts.root_dir = ts_root_dir
      opts.init_options = ts_ls_init_options()
      opts.settings = {
        javascript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
          },
        },
        typescript = {
          inlayHints = {
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayVariableTypeHints = false,
          },
          -- Better perf & correctness in monorepos
          tsserver = {
            maxTsServerMemory = 8192,
            disableAutomaticTypeAcquisition = true,
            disableAutomaticTypingAcquisition = true,
            disableSolutionSearching = true,
            watchOptions = {
              watchFile = "useFsEvents",
              watchDirectory = "useFsEvents",
              fallbackPolling = "dynamicPriority",
              synchronousWatchDirectory = false,
              excludeDirectories = {
                "**/node_modules",
                "**/.git",
                "**/dist",
                "**/build",
              },
            },
          },
          format = { enable = false }, -- prefer prettier/eslint
        },
      }
    end

    local ok, user_settings = pcall(require, "user.lspsettings." .. server)
    if ok then
      opts = vim.tbl_deep_extend("force", opts, user_settings)
    end

    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
  end
end

return M
