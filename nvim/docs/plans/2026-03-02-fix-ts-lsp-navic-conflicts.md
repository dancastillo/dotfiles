# Neovim TS/Denols/Navic Conflict Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove the startup warnings in the screenshot by eliminating `nvim-lspconfig` framework deprecation usage and preventing `nvim-navic` from attaching to competing LSP clients in the same TypeScript buffer.

**Architecture:** Migrate LSP server registration from `require('lspconfig').<server>.setup()` to Neovim 0.11 native `vim.lsp.config()` + `vim.lsp.enable()`. Then enforce one source of truth for navic attachment by using `nvim-navic` auto-attach with explicit server preference and disabling competing auto-attachers in `barbecue` and `navbuddy`.

**Tech Stack:** Neovim 0.11 LSP API, `neovim/nvim-lspconfig`, `SmiteshP/nvim-navic`, `utilyre/barbecue.nvim`, `SmiteshP/nvim-navbuddy`, Lua.

---

### Task 1: Baseline Reproduction and Guardrails

**Files:**
- Modify: `lua/user/lspconfig.lua`
- Modify: `lua/user/barbecue.lua`
- Modify: `lua/user/navbuddy.lua`
- Modify: `lua/user/navic.lua`

**Step 1: Capture current warning behavior**

Run:
```bash
nvim
```
Expected: `:messages` contains both warning families:
- `nvim-navic: Failed to attach to ts_ls ... Already attached to denols`
- stack trace that includes `.../lazy/nvim-lspconfig/lua/lspconfig.lua:81` (deprecation path)

**Step 2: Capture current LSP state in affected TS buffer**

Run inside Neovim:
```vim
:LspInfo
:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))
:lua print('navic=', vim.b.navic_client_name)
```
Expected now (before fix): both `ts_ls` and `denols` may appear; navic is attached to one and warns for the other.

**Step 3: Commit baseline notes only (no code yet)**

```bash
git add -N lua/user/lspconfig.lua lua/user/barbecue.lua lua/user/navbuddy.lua lua/user/navic.lua
git status --short
```
Expected: files visible as intent-to-add changes only if needed for tracking.

---

### Task 2: Remove Deprecated `require('lspconfig')` Framework Calls

**Files:**
- Modify: `lua/user/lspconfig.lua:159`
- Modify: `lua/user/lspconfig.lua:208`
- Modify: `lua/user/lspconfig.lua:306`

**Step 1: Write failing check for deprecated API usage**

Run:
```bash
rg --line-number "lspconfig\.[a-z_]+\.setup\(|lspconfig\[server\]\.setup\(" lua/user/lspconfig.lua
```
Expected: matches at `denols.setup` and `lspconfig[server].setup(opts)`.

**Step 2: Implement minimal migration to native API**

Replace framework setup calls with native config/enable.

```lua
-- before (deprecated)
-- lspconfig.denols.setup(deno_opts)
-- lspconfig[server].setup(opts)

-- after (Neovim 0.11 style)
vim.lsp.config("denols", deno_opts)
vim.lsp.config(server, opts)

-- enable after config
vim.lsp.enable("denols") -- only if deno mode is enabled in Task 3
vim.lsp.enable(server)
```

Keep `require("lspconfig.util")` for root helpers if needed, but stop indexing servers through `require("lspconfig")`.

**Step 3: Verify deprecated usage removed**

Run:
```bash
rg --line-number "lspconfig\.[a-z_]+\.setup\(|lspconfig\[server\]\.setup\(" lua/user/lspconfig.lua
```
Expected: no matches.

**Step 4: Runtime verification in Neovim**

Run:
```bash
nvim
```
Then in Neovim:
```vim
:messages
```
Expected: no warning trace referencing `.../lspconfig.lua:81` from framework deprecation.

**Step 5: Commit**

```bash
git add lua/user/lspconfig.lua
git commit -m "refactor: migrate nvim lsp setup to native 0.11 api"
```

---

### Task 3: Enforce Mutual Exclusivity Between `ts_ls` and `denols`

**Files:**
- Modify: `lua/user/lspconfig.lua:162-231`
- Modify: `lua/user/lspconfig.lua:254-266`

**Step 1: Write failing check for broad TS root fallback**

Run:
```bash
rg --line-number "find_node_modules_ancestor|autostart = false|client\.stop\(true\)" lua/user/lspconfig.lua
```
Expected: fallback/root and force-stop logic present.

**Step 2: Implement deterministic server policy**

Use one switch and clear rules:
- `vim.g.enable_denols = true` => enable `denols` only for `deno.json|deno.jsonc` roots, and disable `ts_ls` in those roots.
- default (`false`/unset) => do not enable `denols`; use `ts_ls` only.

```lua
local function deno_root(fname)
  return util.root_pattern("deno.json", "deno.jsonc")(fname)
end

local function ts_root_dir(fname)
  if vim.g.enable_denols and deno_root(fname) then
    return nil
  end
  return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json")(fname)
end
```

Remove the `LspAttach` autocmd that force-stops `denols`; rely on root gating instead.

**Step 3: Verify server exclusivity in runtime**

Open a TypeScript file in a Node project and run:
```vim
:LspInfo
```
Expected: only `ts_ls` attached.

If testing a Deno project with `vim.g.enable_denols = true`:
```vim
:LspInfo
```
Expected: only `denols` attached (no `ts_ls`).

**Step 4: Commit**

```bash
git add lua/user/lspconfig.lua
git commit -m "fix: make ts_ls and denols mutually exclusive by root"
```

---

### Task 4: Use a Single Navic Attachment Path With Preference

**Files:**
- Modify: `lua/user/navic.lua`
- Modify: `lua/user/barbecue.lua`
- Modify: `lua/user/navbuddy.lua`

**Step 1: Write failing check for competing navic attachers**

Run:
```bash
rg --line-number "attach_navic|auto_attach" lua/user/{barbecue,navbuddy,navic}.lua
```
Expected now: multiple auto-attach paths (`barbecue` and `navbuddy`), while `navic.lua` setup is commented out.

**Step 2: Implement single-owner navic configuration**

`lua/user/navic.lua`:
```lua
require("nvim-navic").setup({
  icons = require("user.icons").kind,
  highlight = true,
  click = true,
  lsp = {
    auto_attach = true,
    preference = { "ts_ls", "denols" },
  },
})
```

`lua/user/barbecue.lua`:
```lua
require("barbecue").setup({
  attach_navic = false,
  -- existing options ...
})
```

`lua/user/navbuddy.lua`:
```lua
navbuddy.setup({
  -- existing options ...
  lsp = { auto_attach = false },
})
```

**Step 3: Verify navic warning is gone**

Run:
```bash
nvim
```
Then in Neovim:
```vim
:messages
:lua print('navic=', vim.b.navic_client_name)
```
Expected:
- no `nvim-navic: Failed to attach ... Already attached ...` warning
- `vim.b.navic_client_name` stable and matches preferred active server.

**Step 4: Commit**

```bash
git add lua/user/navic.lua lua/user/barbecue.lua lua/user/navbuddy.lua
git commit -m "fix: consolidate navic attachment and set lsp preference"
```

---

### Task 5: Final Validation Matrix

**Files:**
- Test: `lua/user/lspconfig.lua`
- Test: `lua/user/navic.lua`
- Test: `lua/user/barbecue.lua`
- Test: `lua/user/navbuddy.lua`

**Step 1: Health and config checks**

Run:
```bash
nvim --headless "+checkhealth" +qa
```
Expected: no new LSP/navic/barbecue/navbuddy errors introduced by this change.

**Step 2: Interactive regression checks**

Run in normal Neovim session:
```vim
:LspInfo
:messages
:lua print(vim.inspect(vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))))
```
Expected:
- No `lspconfig.lua:81` deprecation trace
- No navic multi-attach warning
- Exactly one TypeScript-family server per TS buffer

**Step 3: Final commit**

```bash
git log --oneline -n 5
```
Expected: 3 focused commits from Tasks 2-4.
