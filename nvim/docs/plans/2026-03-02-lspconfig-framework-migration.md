# Lspconfig Framework Deprecation Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove the `require('lspconfig')` framework deprecation warning by migrating server setup to Neovim 0.11 native `vim.lsp.config()` and `vim.lsp.enable()`.

**Architecture:** Keep existing server options and root detection logic, but replace legacy `lspconfig.<server>.setup(...)` calls with the native config registry API. Ensure each configured server is explicitly enabled so behavior remains unchanged while removing deprecated code paths.

**Tech Stack:** Neovim 0.11 LSP API, nvim-lspconfig server configs (`lsp/`), Lua.

---

### Task 1: Identify and Lock Deprecated Call Sites

**Files:**
- Modify: `lua/user/lspconfig.lua`

**Step 1: Write failing deprecation check**

Run:
```bash
rg --line-number "require\(\"lspconfig\"\)|lspconfig\.[a-z_]+\.setup\(|lspconfig\[server\]\.setup\(" lua/user/lspconfig.lua
```

Expected: matches at:
- `local lspconfig = require("lspconfig")`
- `lspconfig.denols.setup(...)`
- `lspconfig[server].setup(opts)`

**Step 2: Confirm stacktrace maps to those lines**

Run:
```bash
nl -ba lua/user/lspconfig.lua | sed -n '150,320p'
```

Expected: your reported stack frame around line `208` points to `lspconfig.denols.setup`.

**Step 3: Commit checkpoint**

```bash
git add -N lua/user/lspconfig.lua
git status --short
```

Expected: file staged as intent-only checkpoint.

---

### Task 2: Migrate Config Registration to `vim.lsp.config`

**Files:**
- Modify: `lua/user/lspconfig.lua:159`
- Modify: `lua/user/lspconfig.lua:208`
- Modify: `lua/user/lspconfig.lua:306`

**Step 1: Write failing assertion for legacy setup calls**

Run:
```bash
rg --line-number "lspconfig\.[a-z_]+\.setup\(|lspconfig\[server\]\.setup\(" lua/user/lspconfig.lua
```

Expected: 2 matches.

**Step 2: Replace deprecated server setup calls**

Apply this migration pattern:

```lua
-- Before
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

lspconfig.denols.setup(denols_opts)
...
lspconfig[server].setup(opts)

-- After
local util = require("lspconfig.util")

vim.lsp.config("denols", denols_opts)
...
vim.lsp.config(server, opts)
```

Notes:
- Keep `require("lspconfig.util")` only for helper functions (`root_pattern`, etc).
- Do not call `require('lspconfig')[...]` anywhere.

**Step 3: Verify no legacy setup remains**

Run:
```bash
rg --line-number "require\(\"lspconfig\"\)|lspconfig\.[a-z_]+\.setup\(|lspconfig\[server\]\.setup\(" lua/user/lspconfig.lua
```

Expected: no matches.

**Step 4: Commit**

```bash
git add lua/user/lspconfig.lua
git commit -m "refactor: migrate lsp setup to vim.lsp.config"
```

---

### Task 3: Explicitly Enable Registered Servers with `vim.lsp.enable`

**Files:**
- Modify: `lua/user/lspconfig.lua`

**Step 1: Write failing runtime check (server configured but not enabled risk)**

Open Neovim and run:
```vim
:LspInfo
```

Expected before this task: possible mismatch if configs are registered but not enabled after migration.

**Step 2: Enable servers after registration**

Add explicit enables:

```lua
vim.lsp.config("denols", denols_opts)
vim.lsp.enable("denols")

for _, server in ipairs(servers) do
  vim.lsp.config(server, opts)
  vim.lsp.enable(server)
end
```

If you intentionally keep Deno disabled by default, gate enable behind a flag:

```lua
if vim.g.enable_denols == true then
  vim.lsp.enable("denols")
end
```

**Step 3: Verify runtime activation**

Open a TS file and run:
```vim
:LspInfo
```

Expected: `ts_ls` starts as before; no missing LSP behavior introduced by migration.

**Step 4: Commit**

```bash
git add lua/user/lspconfig.lua
git commit -m "fix: enable migrated lsp configs via vim.lsp.enable"
```

---

### Task 4: Validate Deprecation Is Fully Removed

**Files:**
- Test: `lua/user/lspconfig.lua`

**Step 1: Reproduce original startup path**

Run:
```bash
nvim
```

Then inspect:
```vim
:messages
```

Expected: no message containing:
- `The require('lspconfig') "framework" is deprecated`
- `.../lua/lspconfig.lua:81`

**Step 2: Health check**

Run:
```bash
nvim --headless "+checkhealth vim.lsp" +qa
```

Expected: no new errors introduced by migration.

**Step 3: Final commit**

```bash
git log --oneline -n 5
```

Expected: focused commits showing API migration and enablement.
