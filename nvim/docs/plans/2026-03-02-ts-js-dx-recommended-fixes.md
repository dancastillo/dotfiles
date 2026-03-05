# TS/JS Developer Experience Hardening Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Apply the selected six fixes to make this Neovim config reliable and fast for TypeScript/JavaScript frontend and backend work, with an implementation confidence target of >=95%.

**Architecture:** Keep `ts_ls` as the primary TS/JS language server, add `eslint` LSP for diagnostics/fixes, and keep Deno opt-in only. Replace legacy `none-ls` formatting with `conform.nvim` + `nvim-lint`, make Treesitter load at startup (per upstream guidance), restore snippet expansion in `nvim-cmp`, and simplify AI workflow by removing `avante.nvim` while keeping `opencode.nvim` + `copilot.lua`.

**Tech Stack:** Neovim 0.11 LSP (`vim.lsp.config` / `vim.lsp.enable`), `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`, `conform.nvim`, `nvim-lint`, `nvim-treesitter`, `nvim-cmp`, `LuaSnip`, `opencode.nvim`, `copilot.lua`.

---

### Task 1: Standardize TS/JS LSP (`ts_ls` + `eslint`, Deno opt-in)

**Files:**
- Modify: `lua/user/lspconfig.lua`
- Modify: `lua/user/mason.lua`
- Create: `lua/user/lspsettings/eslint.lua`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "\beslint\b|enable_denols|denols|ts_ls" lua/user/lspconfig.lua lua/user/mason.lua lua/user/lspsettings
```

Expected: `eslint` not fully wired as an active LSP config in both Mason and LSP server list.

**Step 2: Run check to verify it fails**

Run:
```bash
nvim --headless "+lua local names=vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({bufnr=0})); print(vim.inspect(names))" +qa
```

Expected: no stable `eslint` LSP integration yet.

**Step 3: Write minimal implementation**

`lua/user/mason.lua` add eslint install target:
```lua
local servers = {
  "lua_ls", "cssls", "html", "ts_ls", "eslint", "bashls", "jsonls", "yamlls", "marksman", "tailwindcss"
}

require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = { "denols" },
  },
}
```

`lua/user/lspconfig.lua` add `eslint` server and keep Deno gated:
```lua
local servers = {
  "lua_ls", "cssls", "html", "ts_ls", "eslint", "pyright", "bashls", "jsonls", "yamlls", "marksman", "tailwindcss",
}

if vim.g.enable_denols == true then
  vim.lsp.enable("denols")
end
```

`lua/user/lspsettings/eslint.lua`:
```lua
return {
  settings = {
    workingDirectory = { mode = "auto" },
    format = false,
    codeActionOnSave = {
      enable = true,
      mode = "all",
    },
  },
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "\beslint\b" lua/user/lspconfig.lua lua/user/mason.lua lua/user/lspsettings/eslint.lua
```

Expected: matches in all three files.

**Step 5: Commit**

```bash
git add lua/user/lspconfig.lua lua/user/mason.lua lua/user/lspsettings/eslint.lua
git commit -m "feat: standardize ts/js lsp with ts_ls and eslint"
```

---

### Task 2: Replace `none-ls` with `conform.nvim` + `nvim-lint`

**Files:**
- Modify: `init.lua`
- Create: `lua/user/conform.lua`
- Create: `lua/user/lint.lua`
- Delete: `lua/user/none-ls.lua`
- Modify: `lua/user/options.lua`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "spec \"user.none-ls\"|none-ls|null-ls|conform|nvim-lint" init.lua lua/user
```

Expected: `none-ls` present; `conform` and `nvim-lint` missing.

**Step 2: Run check to verify it fails**

Run:
```bash
nvim --headless "+lua print(vim.fn.exists(':ConformInfo'), vim.fn.exists(':LintInfo'))" +qa
```

Expected: commands not available yet.

**Step 3: Write minimal implementation**

`init.lua` plugin specs:
```lua
spec "user.conform"
spec "user.lint"
-- remove: spec "user.none-ls"
```

`lua/user/conform.lua`:
```lua
local M = {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
}

function M.config()
  require("conform").setup({
    formatters_by_ft = {
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 3000,
      lsp_fallback = true,
    },
  })
end

return M
```

`lua/user/lint.lua`:
```lua
local M = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
}

function M.config()
  local lint = require("lint")
  lint.linters_by_ft = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
  }

  local group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = group,
    callback = function()
      lint.try_lint()
    end,
  })
end

return M
```

`lua/user/options.lua` format keymap:
```lua
vim.keymap.set('n', '<space>f', function()
  require('conform').format({ async = true, lsp_fallback = true })
end, { noremap = true, silent = true })
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "spec \"user.conform\"|spec \"user.lint\"|none-ls|null-ls" init.lua lua/user
```

Expected: `conform` + `lint` present, `none-ls` removed from active config.

**Step 5: Commit**

```bash
git add init.lua lua/user/conform.lua lua/user/lint.lua lua/user/options.lua lua/user/none-ls.lua
git commit -m "refactor: migrate js/ts format and lint from none-ls to conform+nvim-lint"
```

---

### Task 3: Keep Mason exclusions explicit and auditable

**Files:**
- Modify: `lua/user/mason.lua`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "automatic_enable|exclude" lua/user/mason.lua
```

Expected: exclusion exists but not documented/auditable enough for future edits.

**Step 2: Run check to verify it fails**

Run:
```bash
rg --line-number "denols" lua/user/mason.lua
```

Expected: no inline rationale.

**Step 3: Write minimal implementation**

Add explicit comment and constant:
```lua
local AUTO_ENABLE_EXCLUDE = { "denols" } -- keep deno opt-in only

require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = AUTO_ENABLE_EXCLUDE,
  },
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "AUTO_ENABLE_EXCLUDE|deno opt-in" lua/user/mason.lua
```

Expected: both found.

**Step 5: Commit**

```bash
git add lua/user/mason.lua
git commit -m "chore: document mason auto-enable exclusions"
```

---

### Task 4: Make Treesitter non-lazy (startup-safe)

**Files:**
- Modify: `lua/user/treesitter.lua`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "event = \{ \"BufReadPost\", \"BufNewFile\" \}|lazy =" lua/user/treesitter.lua
```

Expected: plugin is lazy by buffer events.

**Step 2: Run check to verify it fails**

Run:
```bash
nvim --headless "+TSInstallInfo" +qa
```

Expected: may race with lazy load in some sessions.

**Step 3: Write minimal implementation**

Use startup load:
```lua
local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  ...
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "lazy = false|event =" lua/user/treesitter.lua
```

Expected: `lazy = false` present; event-based lazy-loading removed.

**Step 5: Commit**

```bash
git add lua/user/treesitter.lua
git commit -m "fix: load treesitter at startup for stable parser behavior"
```

---

### Task 5: Restore snippet expansion in `nvim-cmp`

**Files:**
- Modify: `lua/user/cmp.lua`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "snippet\s*=\s*\{|luasnip\.lsp_expand|cmp_luasnip" lua/user/cmp.lua
```

Expected: snippet expansion block absent/commented while `cmp_luasnip` source is configured.

**Step 2: Run check to verify it fails**

Run:
```bash
nvim --headless "+lua local ok,cmp=pcall(require,'cmp'); print(ok and 'cmp ok' or 'cmp fail')" +qa
```

Expected: cmp loads, but snippet expansion path not defined.

**Step 3: Write minimal implementation**

Uncomment/add:
```lua
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  ...
}
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "snippet\s*=\s*\{|luasnip\.lsp_expand" lua/user/cmp.lua
```

Expected: both present.

**Step 5: Commit**

```bash
git add lua/user/cmp.lua
git commit -m "fix: enable luasnip snippet expansion in nvim-cmp"
```

---

### Task 6: Remove `avante.nvim`, keep `opencode.nvim`

**Files:**
- Modify: `init.lua`
- Delete: `lua/user/avante.lua`
- Modify: `lua/user/opencode.lua` (only if keymap cleanup needed)
- Modify: `lazy-lock.json`

**Step 1: Write the failing check**

Run:
```bash
rg --line-number "spec \"user.avante\"|avante.nvim|opencode.nvim" init.lua lua/user lazy-lock.json
```

Expected: Avante still referenced.

**Step 2: Run check to verify it fails**

Run:
```bash
nvim --headless "+Lazy! show avante.nvim" +qa
```

Expected: Avante is still managed.

**Step 3: Write minimal implementation**

Remove Avante from startup and code:
```lua
-- init.lua
-- remove: spec "user.avante"
-- keep:  spec "user.opencode"
```

Delete file:
```bash
rm lua/user/avante.lua
```

Update lockfile by syncing/cleaning:
```bash
nvim --headless "+Lazy! sync" "+Lazy! clean" +qa
```

**Step 4: Run test to verify it passes**

Run:
```bash
rg --line-number "avante" init.lua lua/user lazy-lock.json || true
rg --line-number "opencode.nvim|spec \"user.opencode\"" init.lua lua/user lazy-lock.json
```

Expected: no `avante` refs in active config; `opencode` retained.

**Step 5: Commit**

```bash
git add init.lua lua/user/avante.lua lua/user/opencode.lua lazy-lock.json
git commit -m "refactor: remove avante and keep opencode ai workflow"
```

---

### Task 7: Final Validation Matrix (confidence gate >=95%)

**Files:**
- Test: `init.lua`
- Test: `lua/user/lspconfig.lua`
- Test: `lua/user/mason.lua`
- Test: `lua/user/cmp.lua`
- Test: `lua/user/treesitter.lua`
- Test: `lua/user/conform.lua`
- Test: `lua/user/lint.lua`

**Step 1: Startup and health checks**

Run:
```bash
nvim --headless "+checkhealth vim.lsp" +qa
nvim --headless "+checkhealth" +qa
```

Expected: no new LSP/completion/formatter/linter regressions caused by this migration.

**Step 2: Interactive TS/JS workflow checks**

In a TS project:
```vim
:LspInfo
:messages
:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))
```

Expected:
- `ts_ls` attached
- `eslint` attached where project supports it
- `denols` absent unless `vim.g.enable_denols = true`
- no `require('lspconfig')` framework deprecation warning

**Step 3: Format/lint save checks**

Run:
```vim
:write
:lua vim.diagnostic.open_float()
```

Expected: Prettier formatting via Conform and lint diagnostics via nvim-lint/eslint_d.

**Step 4: Completion/snippet checks**

In TS file:
- Trigger a LuaSnip snippet and confirm expansion works with `<Tab>` flows.

Expected: snippet insert and jump are functional.

**Step 5: AI workflow checks**

Run:
```vim
:Lazy
```

Expected: `opencode.nvim` present, `avante.nvim` absent.

**Step 6: Final commit audit**

Run:
```bash
git log --oneline -n 10
```

Expected: focused commits for tasks 1-6 and no unrelated churn.
