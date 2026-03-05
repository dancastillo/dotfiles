# TS-LS-Only LSP Startup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ensure TypeScript/JavaScript buffers only use `ts_ls`, and prevent `denols` from auto-starting.

**Architecture:** Disable Mason’s automatic enable path for `denols`, then remove local `denols` setup from user LSP config so there is a single TypeScript LSP source of truth (`ts_ls`). Optionally uninstall Deno from Mason for hard enforcement.

**Tech Stack:** Neovim 0.11 LSP (`vim.lsp.enable`), `mason-lspconfig.nvim`, `nvim-lspconfig`, Lua.

---

### Task 1: Confirm and Capture Root Cause

**Files:**
- Inspect: `lua/user/mason.lua`
- Inspect: `lua/user/lspconfig.lua`

**Step 1: Verify Mason auto-enable default behavior**

Run:
```bash
nl -ba ~/.local/share/nvim/lazy/mason-lspconfig.nvim/lua/mason-lspconfig/settings.lua | sed -n '1,60p'
nl -ba ~/.local/share/nvim/lazy/mason-lspconfig.nvim/lua/mason-lspconfig/features/automatic_enable.lua | sed -n '1,90p'
```
Expected:
- default `automatic_enable = true`
- code path calling `vim.lsp.enable(lspconfig_name)` for installed servers.

**Step 2: Verify Deno package is installed**

Run:
```bash
ls -1 ~/.local/share/nvim/mason/packages | rg -n "^deno$|typescript-language-server"
```
Expected: `deno` and `typescript-language-server` are both present.

**Step 3: Verify local config still registers denols**

Run:
```bash
rg --line-number "denols|autostart = false|client\.stop\(true\)" lua/user/lspconfig.lua
```
Expected: local denols setup exists, but Mason auto-enable is the independent startup path.

---

### Task 2: Stop Mason From Enabling `denols`

**Files:**
- Modify: `lua/user/mason.lua`

**Step 1: Add `automatic_enable` policy with explicit exclusion**

Update Mason setup:

```lua
require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_installation = true,
  automatic_enable = {
    exclude = { "denols" },
  },
}
```

**Step 2: Verify config contains exclusion**

Run:
```bash
rg --line-number "automatic_enable|denols" lua/user/mason.lua
```
Expected: `denols` is explicitly excluded.

**Step 3: Commit**

```bash
git add lua/user/mason.lua
git commit -m "fix: exclude denols from mason automatic lsp enable"
```

---

### Task 3: Remove Local `denols` Setup From User LSP Config

**Files:**
- Modify: `lua/user/lspconfig.lua`

**Step 1: Remove denols-specific setup and stop autocmd**

Delete:
- `lspconfig.denols.setup({ ... })`
- `LspAttach` autocmd that checks `client.name == "denols"` and stops it.
- `on_attach` handler overrides specific to `denols` diagnostics suppression.

Keep `ts_ls` logic and root selection focused on Node/TS markers.

**Step 2: Simplify `ts_root_dir`**

Replace deno gate with TS-only logic:

```lua
local function ts_root_dir(fname)
  return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(fname)
         or util.find_node_modules_ancestor(fname)
end
```

**Step 3: Verify denols references removed**

Run:
```bash
rg --line-number "denols|deno\.json|client\.stop\(true\)" lua/user/lspconfig.lua
```
Expected: no matches related to active denols control.

**Step 4: Commit**

```bash
git add lua/user/lspconfig.lua
git commit -m "refactor: remove denols config and keep ts_ls as sole ts lsp"
```

---

### Task 4: Hard-Enforce by Uninstalling Deno LSP (Optional but Recommended)

**Files:**
- Runtime state only (Mason packages)

**Step 1: Uninstall Deno from Mason**

Run in Neovim:
```vim
:MasonUninstall deno
```

or shell:
```bash
rm -rf ~/.local/share/nvim/mason/packages/deno
```

**Step 2: Verify it is gone**

Run:
```bash
ls -1 ~/.local/share/nvim/mason/packages | rg -n "^deno$" || echo "deno not installed"
```
Expected: no `deno` package present.

---

### Task 5: Runtime Validation (`ts_ls` Only)

**Files:**
- Test: `lua/user/mason.lua`
- Test: `lua/user/lspconfig.lua`

**Step 1: Start Neovim in a TS file**

Run in Neovim:
```vim
:LspInfo
:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))
:messages
```
Expected:
- `ts_ls` is attached
- `denols` is not attached
- no navic warning: `Already attached to denols`

**Step 2: Restart check**

Restart Neovim and re-run same checks to ensure no startup race reintroduces `denols`.

**Step 3: Final commit audit**

```bash
git log --oneline -n 5
```
Expected: focused commits for Mason exclusion and LSP cleanup.
