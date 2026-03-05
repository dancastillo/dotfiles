# Neovim Performance + TypeScript DX Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce warm startup from ~145ms toward ~95-115ms while improving TypeScript/LSP reliability and removing high-noise runtime behavior.

**Architecture:** Keep core editing UX immediate (theme, keymaps, essential LSP), move non-critical integrations behind explicit lazy triggers, and remove duplicate/conflicting specs. Stabilize TS/LSP by eliminating diagnostic reset hacks and aligning server lifecycle ownership.

**Tech Stack:** Neovim 0.11, lazy.nvim, nvim-lspconfig, typescript-language-server, Mason, Treesitter, Lua.

---

### Task 1: Establish repeatable baseline metrics

**Files:**
- Create: `docs/perf/2026-03-03-baseline.md`
- Test: `init.lua`

**Step 1: Capture cold/warm startup timings**

```bash
for i in 1 2 3 4 5; do
  nvim --headless -i NONE --startuptime /tmp/nvim-startup-$i.log +qa
done
```

**Step 2: Record Lazy stats snapshot**

```bash
nvim --headless -i NONE '+lua print(vim.json.encode(require("lazy").stats()))' +qa
```

**Step 3: Save numeric baseline in markdown**

```markdown
- Warm avg: XXX ms
- Cold run: XXX ms
- lazy.loaded: XX / XX
- Known startup errors: ...
```

**Step 4: Commit**

```bash
git add docs/perf/2026-03-03-baseline.md
git commit -m "chore: record neovim performance baseline"
```

### Task 2: Fix correctness regressions that hurt DX first

**Files:**
- Modify: `lua/user/neotest.lua`
- Modify: `lua/user/treesitter.lua`
- Modify: `lua/user/comment.lua`
- Test: `lazy-lock.json`

**Step 1: Ensure neotest dependency is installed and loaded lazily**

```lua
local M = {
  "nvim-neotest/neotest",
  cmd = { "Neotest", "NeotestRun", "NeotestSummary" },
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Test Nearest" },
  },
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-jest",
  },
}
```

**Step 2: Remove duplicated `nvim-ts-context-commentstring` ownership**

```lua
-- Keep ts-context-commentstring in one place only (Comment.nvim module)
-- Remove duplicate dependency declaration from treesitter.lua
```

**Step 3: Run plugin sync and lock update**

Run: `nvim --headless '+Lazy sync' +qa`
Expected: no missing `nvim-nio`; lockfile updated if needed.

**Step 4: Run startup sanity check**

Run: `nvim --headless -i NONE +qa`
Expected: no `neotest requires nvim-nio` error.

**Step 5: Commit**

```bash
git add lua/user/neotest.lua lua/user/treesitter.lua lua/user/comment.lua lazy-lock.json
git commit -m "fix: restore neotest dependency and remove duplicate treesitter glue"
```

### Task 3: Remove duplicate plugin registrations and contradictory lazy settings

**Files:**
- Modify: `init.lua`
- Modify: `lua/user/whichkey.lua`
- Modify: `lua/user/treesitter.lua`
- Modify: `lua/user/dap.lua`

**Step 1: Remove duplicate plugin spec entries**

```lua
-- init.lua
-- keep one: spec "user.oil"
```

**Step 2: Fix contradictory lazy config**

```lua
-- whichkey.lua
event = "VeryLazy"
-- remove: lazy = false
```

**Step 3: Drop duplicate `nvim-autopairs` registration**

```lua
-- treesitter.lua
-- remove dependency entry for "windwp/nvim-autopairs"
-- keep ownership in lua/user/autopairs.lua
```

**Step 4: Remove debug spam from DAP config**

```lua
-- dap.lua
-- remove print(vim.fn.stdpath)
-- set dap.set_log_level("ERROR")
```

**Step 5: Verify startup no duplicate warnings**

Run: `nvim --headless -i NONE '+Lazy check' +qa`
Expected: no duplicate spec warnings.

**Step 6: Commit**

```bash
git add init.lua lua/user/whichkey.lua lua/user/treesitter.lua lua/user/dap.lua
git commit -m "perf: remove duplicate specs and contradictory lazy settings"
```

### Task 4: Convert non-essential startup plugins to explicit lazy triggers

**Files:**
- Modify: `lua/user/lualine.lua`
- Modify: `lua/user/fidget.lua`
- Modify: `lua/user/navbuddy.lua`
- Modify: `lua/user/oil.lua`
- Modify: `lua/user/lab.lua`
- Modify: `lua/user/graphql.lua`
- Modify: `lua/user/polar.lua`
- Modify: `lua/user/surround.lua`

**Step 1: Gate statusline and notifications behind editor-ready events**

```lua
-- lualine.lua
event = "VeryLazy"

-- fidget.lua
event = "LspAttach"
```

**Step 2: Gate rare tools behind cmd/keys/filetype**

```lua
-- navbuddy.lua
cmd = { "Navbuddy" }
keys = { { "<leader>n", "<cmd>Navbuddy<cr>", desc = "Nav" } }

-- oil.lua
cmd = { "Oil" }
keys = { { "-", "<CMD>Oil --float<CR>", desc = "Open parent directory" } }

-- lab.lua
cmd = { "Lab" }

-- graphql.lua
ft = { "graphql", "typescriptreact", "javascriptreact" }

-- surround.lua
event = "VeryLazy"
```

**Step 3: Keep only one primary file explorer plugin**

```lua
-- Choose one of:
-- A) nvim-tree
-- B) oil.nvim
-- C) netrw.nvim
-- Disable the other two specs.
```

**Step 4: Re-run startup profile**

Run: `nvim --headless -i NONE --startuptime /tmp/nvim-after-lazy.log +qa`
Expected: warm startup improvement >= 15-25ms.

**Step 5: Commit**

```bash
git add lua/user/lualine.lua lua/user/fidget.lua lua/user/navbuddy.lua lua/user/oil.lua lua/user/lab.lua lua/user/graphql.lua lua/user/polar.lua lua/user/surround.lua init.lua lua/user/netrw.lua lua/user/nvimtree.lua
git commit -m "perf: lazy-load non-essential plugins and simplify explorer stack"
```

### Task 5: Reduce always-on runtime overhead in large Node/TS repos

**Files:**
- Modify: `lua/user/nvimtree.lua`
- Modify: `lua/user/gitsigns.lua`
- Modify: `lua/user/autocmds.lua`

**Step 1: Disable nvim-tree logging in normal usage**

```lua
log = { enable = false }
```

**Step 2: Disable expensive default line blame**

```lua
current_line_blame = false
```

**Step 3: Stop global `checktime` on every `BufWinEnter`**

```lua
-- replace BufWinEnter checktime with FocusGained/BufEnter throttled check
```

**Step 4: Validate responsiveness on a large monorepo**

Run: open a large TS workspace and measure cursor latency, write/save latency.
Expected: reduced UI churn and fewer redraw spikes.

**Step 5: Commit**

```bash
git add lua/user/nvimtree.lua lua/user/gitsigns.lua lua/user/autocmds.lua
git commit -m "perf: reduce always-on filesystem and redraw overhead"
```

### Task 6: Simplify TypeScript diagnostic lifecycle and remove reset hacks

**Files:**
- Modify: `lua/user/ts-sync.lua`
- Modify: `lua/user/lspconfig.lua`
- Modify: `lua/user/mason.lua`

**Step 1: Remove automatic diagnostic reset autocmds**

```lua
-- ts-sync.lua
-- delete BufWritePost/FocusGained diagnostic.reset behavior
-- keep only explicit user commands (manual recovery)
```

**Step 2: Ensure one owner for LSP enablement**

```lua
-- Option A: keep vim.lsp.enable(server) loop in lspconfig.lua
-- Option B: keep mason-lspconfig automatic_enable
-- choose exactly one; disable the other
```

**Step 3: Keep tsserver watch options aligned with official TS docs**

```lua
watchOptions = {
  watchFile = "useFsEvents",
  watchDirectory = "useFsEvents",
  fallbackPolling = "dynamicPriority",
  synchronousWatchDirectory = false,
  excludeDirectories = { "**/node_modules", "**/.git", "**/dist", "**/build" },
}
```

**Step 4: Verify LSP health**

Run: `nvim --headless '+checkhealth vim.lsp' +qa`
Expected: no duplicate-client behavior; stable TS diagnostics after save/focus.

**Step 5: Commit**

```bash
git add lua/user/ts-sync.lua lua/user/lspconfig.lua lua/user/mason.lua
git commit -m "fix: stabilize ts lsp lifecycle and remove diagnostic reset hacks"
```

### Task 7: Final validation and documented targets

**Files:**
- Modify: `docs/perf/2026-03-03-baseline.md`
- Create: `docs/perf/2026-03-03-after.md`

**Step 1: Capture after metrics with same commands as baseline**

```bash
for i in 1 2 3 4 5; do
  nvim --headless -i NONE --startuptime /tmp/nvim-after-$i.log +qa
done
```

**Step 2: Publish before/after comparison**

```markdown
- Startup: before vs after
- lazy.loaded ratio: before vs after
- Error count at startup: before vs after
- Subjective UX: test run, LSP actions, completion latency
```

**Step 3: Commit**

```bash
git add docs/perf/2026-03-03-baseline.md docs/perf/2026-03-03-after.md
git commit -m "docs: publish neovim performance and dx improvements"
```

### Task 8: Optional expert hardening track

**Files:**
- Modify: `init.lua`
- Modify: `lua/user/lazy.lua`
- Modify: `lua/user/lspconfig.lua`

**Step 1: Add feature flags for heavy integrations**

```lua
vim.g.enable_ai = true
vim.g.enable_dap = true
vim.g.enable_navbuddy = false
```

**Step 2: Conditionalize specs based on flags**

```lua
if vim.g.enable_dap then spec("user.dap") end
```

**Step 3: Add lightweight startup self-check command**

```lua
vim.api.nvim_create_user_command("PerfSnapshot", function()
  print(vim.json.encode(require("lazy").stats()))
end, {})
```

**Step 4: Commit**

```bash
git add init.lua lua/user/lazy.lua lua/user/lspconfig.lua
git commit -m "feat: add feature flags and perf snapshot command"
```

## Notes for implementer

- Use `@node-best-practices` when tuning Node/TS watchers and memory behavior.
- Keep Treesitter as a startup plugin (upstream does not support true lazy loading).
- Favor one plugin owner per concern (single source of truth for comments, explorer, diagnostics, and LSP lifecycle).
