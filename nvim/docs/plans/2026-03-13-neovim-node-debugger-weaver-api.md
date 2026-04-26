# Neovim + Weaver API Node Debugger Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make Neovim DAP reliably debug local Node.js services in `/Users/dancastillo/jasper/weaver-api`, starting with `core-api`, with working TypeScript breakpoints and a repeatable attach workflow.

**Architecture:** Fix this from the bottom up. First make the Neovim DAP stack boot cleanly, then normalize the JavaScript adapter setup around `vscode-js-debug` and `pwa-node`, then add explicit local attach profiles that match `weaver-api`'s real `scripts/dev.mjs --inspect=<port>` flow instead of stale remote-path assumptions. Keep editor-specific behavior in `/Users/dancastillo/.config/nvim/lua/user/dap.lua`, and keep repo-specific launch profiles/documentation in `/Users/dancastillo/jasper/weaver-api`.

**Tech Stack:** Neovim Lua, lazy.nvim, `mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui`, `nvim-neotest/nvim-nio`, `mxsdev/nvim-dap-vscode-js`, `microsoft/vscode-js-debug`, Node.js, pnpm, TypeScript, NestJS.

---

## Current Findings

- `/Users/dancastillo/.config/nvim/lua/user/dap.lua` loads `nvim-dap-ui` without declaring `nvim-nio` as a dependency, and the current runtime fails with `nvim-dap-ui requires nvim-nio to be installed`.
- The built-in Neovim config named `Attach to existing \`node --inspect\` process` is invalid right now because it has no `port`, `processId`, or equivalent attach target.
- `/Users/dancastillo/.config/nvim/lua/user/dap.lua` mixes `dap-vscode-js` adapter setup with hand-rolled `node` / `node2` adapters, which makes the effective Node adapter path harder to reason about.
- `/Users/dancastillo/jasper/weaver-api/scripts/dev.mjs` already starts apps with `--inspect=<port>`, so attach-by-port should be the primary path.
- `/Users/dancastillo/jasper/weaver-api/.vscode/launch.json` still carries `localRoot` / `remoteRoot: "/usr/app"` mappings that are for remote/container debugging, not the local `pnpm dev` workflow.

### Task 1: Make the DAP stack boot cleanly

**Files:**
- Modify: `/Users/dancastillo/.config/nvim/lua/user/dap.lua`
- Test: `/Users/dancastillo/.config/nvim/lua/user/dap.lua`

**Step 1: Capture the current failing smoke test**

Run:

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+lua require('user.dap').config()" +qa
```

Expected: FAIL with `nvim-dap-ui requires nvim-nio to be installed`.

**Step 2: Add the missing runtime dependency**

Update the `rcarriga/nvim-dap-ui` entry inside `/Users/dancastillo/.config/nvim/lua/user/dap.lua` so it explicitly depends on `nvim-neotest/nvim-nio`:

```lua
{
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "nvim-neotest/nvim-nio",
  },
},
```

Do not rely on `/Users/dancastillo/.config/nvim/lua/user/neotest.lua` loading `nvim-nio` indirectly. `dap.lua` must be self-sufficient.

**Step 3: Keep the DAP UI load path minimal**

Do not add defensive `pcall(require, "dapui")` wrappers yet. First make the plugin graph correct and keep the failure loud if the dependency disappears again.

**Step 4: Re-run the smoke test**

Run:

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+lua require('user.dap').config()" +qa
```

Expected: PASS with no `nvim-nio` / `dapui` bootstrap error.

**Step 5: Commit**

```bash
git -C /Users/dancastillo/.config/nvim add lua/user/dap.lua
git -C /Users/dancastillo/.config/nvim commit -m "fix: add missing nvim-nio dependency for dap ui"
```

### Task 2: Replace the broken Node attach config with valid `pwa-node` setup

**Files:**
- Modify: `/Users/dancastillo/.config/nvim/lua/user/dap.lua`
- Test: `/Users/dancastillo/.config/nvim/lua/user/dap.lua`

**Step 1: Prove the current attach config is invalid**

Run:

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+lua require('user.dap').config(); local dap=require('dap'); local cfg=nil; for _, item in ipairs(dap.configurations.typescript or {}) do if item.name == 'Attach to existing `node --inspect` process' then cfg=item end end; assert(cfg, 'attach config missing'); assert(cfg.port or cfg.processId or cfg.attachSimplePort, 'attach config missing target')" +qa
```

Expected: FAIL with `attach config missing target`.

**Step 2: Normalize the adapter layer around `dap-vscode-js`**

Edit `/Users/dancastillo/.config/nvim/lua/user/dap.lua` with these rules:

- Remove the hand-written `dap.adapters.node2` block entirely.
- Stop hardcoding `"node"` as a blind string. Resolve it once with `vim.fn.exepath("node")` and fail loudly if it is empty.
- Keep `dap-vscode-js` as the source of truth for `pwa-node`.
- Add a `node` alias so loaded VS Code configs with `"type": "node"` still route through the `pwa-node` adapter.
- Use the installed JSON5 parser already present in the repo instead of `overseer.json`.

Use code shaped like this:

```lua
local function require_node()
  local node = vim.fn.exepath("node")
  assert(node ~= "", "node executable not found for vscode-js-debug")
  return node
end

dap_js.setup {
  node_path = require_node(),
  debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
  adapters = { "pwa-node", "node-terminal" },
}

dap.adapters.node = function(cb, config)
  config.type = "pwa-node"
  local adapter = dap.adapters["pwa-node"]
  if type(adapter) == "function" then
    adapter(cb, config)
  else
    cb(adapter)
  end
end

require("dap.ext.vscode").json_decode = require("json5").parse
```

**Step 3: Fix the generic attach config**

Replace the current invalid config:

```lua
{
  name = "Attach to existing `node --inspect` process",
  type = "pwa-node",
  request = "attach",
  cwd = vim.fn.getcwd(),
}
```

with a real attach config:

```lua
{
  name = "Attach to existing `node --inspect` process",
  type = "pwa-node",
  request = "attach",
  processId = require("dap.utils").pick_process,
  cwd = "${workspaceFolder}",
  restart = true,
  sourceMaps = true,
  skipFiles = { "<node_internals>/**", "node_modules/**" },
  resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
}
```

Keep `Debug Jest Tests`, but do not keep any config that cannot possibly attach to a target.

**Step 4: Re-run the headless assertion**

Run:

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+lua require('user.dap').config(); local dap=require('dap'); assert(dap.adapters['pwa-node'], 'missing pwa-node adapter'); assert(dap.adapters['node'], 'missing node alias'); local ok=false; for _, item in ipairs(dap.configurations.typescript or {}) do if item.name == 'Attach to existing `node --inspect` process' and (item.port or item.processId or item.attachSimplePort) then ok=true end end; assert(ok, 'fixed attach config missing')" +qa
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /Users/dancastillo/.config/nvim add lua/user/dap.lua
git -C /Users/dancastillo/.config/nvim commit -m "fix: normalize node dap configuration around pwa-node"
```

### Task 3: Add `weaver-api` local attach profiles that match the real dev ports

**Files:**
- Modify: `/Users/dancastillo/.config/nvim/lua/user/dap.lua`
- Modify: `/Users/dancastillo/jasper/weaver-api/.vscode/launch.json`
- Reference: `/Users/dancastillo/jasper/weaver-api/scripts/dev.mjs`
- Reference: `/Users/dancastillo/jasper/weaver-api/README.md`

**Step 1: Prove the repo is missing a local-first Core API attach profile**

Run:

```bash
cd /Users/dancastillo/jasper/weaver-api
rg -n '"name": "Debugger - CoreAPI \\(Local\\)"' .vscode/launch.json
```

Expected: FAIL with exit code `1`.

**Step 2: Add monorepo-aware Neovim configs for the services you actually debug**

In `/Users/dancastillo/.config/nvim/lua/user/dap.lua`, add a helper that resolves the workspace root by looking upward for `pnpm-workspace.yaml` or `.git`, then add service-specific attach configs.

Use code shaped like this:

```lua
local function current_workspace_root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
  local marker = vim.fs.find({ "pnpm-workspace.yaml", ".git" }, { upward = true, path = start })[1]
  return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

local function attach_by_port(name, port)
  return {
    name = name,
    type = "pwa-node",
    request = "attach",
    address = "127.0.0.1",
    port = port,
    cwd = current_workspace_root,
    restart = true,
    sourceMaps = true,
    skipFiles = { "<node_internals>/**", "node_modules/**" },
    outFiles = {
      "${workspaceFolder}/apps/*/dist/**/*.js",
      "${workspaceFolder}/libs/*/dist/**/*.js",
    },
    resolveSourceMapLocations = {
      "${workspaceFolder}/**",
      "!**/node_modules/**",
    },
  }
end
```

Append at least these configs to each JS/TS filetype:

```lua
attach_by_port("Weaver: Core API (9229)", 9229),
attach_by_port("Weaver: Task Agent Worker (9249)", 9249),
```

If you regularly debug a second service, add it now. Do not mass-add every service in the repo on the first pass.

**Step 3: Add a matching local launch profile to `weaver-api`**

In `/Users/dancastillo/jasper/weaver-api/.vscode/launch.json`, add a new local profile for Core API instead of reusing the stale `/usr/app` mapping:

```json
{
  "name": "Debugger - CoreAPI (Local)",
  "type": "node",
  "request": "attach",
  "address": "127.0.0.1",
  "port": 9229,
  "restart": true,
  "cwd": "${workspaceFolder}",
  "sourceMaps": true,
  "skipFiles": [
    "<node_internals>/**",
    "${workspaceFolder}/node_modules/**/*.js"
  ],
  "outFiles": [
    "${workspaceFolder}/apps/*/dist/**/*.js",
    "${workspaceFolder}/libs/*/dist/**/*.js"
  ],
  "resolveSourceMapLocations": [
    "${workspaceFolder}/**",
    "!**/node_modules/**"
  ]
}
```

Do not delete the old remote-style config in the same commit. Keep the diff reversible while you verify the local path works.

**Step 4: Verify the new configs exist where you expect**

Run:

```bash
cd /Users/dancastillo/jasper/weaver-api
rg -n '"name": "Debugger - CoreAPI \\(Local\\)"|"port": 9229|"cwd": "\\$\\{workspaceFolder\\}"' .vscode/launch.json
```

Run:

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+lua require('user.dap').config(); local dap=require('dap'); local names={}; for _, item in ipairs(dap.configurations.typescript or {}) do names[item.name]=true end; assert(names['Weaver: Core API (9229)'], 'missing core-api attach config'); assert(names['Weaver: Task Agent Worker (9249)'], 'missing task-agent-worker attach config')" +qa
```

Expected: both commands PASS.

**Step 5: Commit**

```bash
git -C /Users/dancastillo/.config/nvim add lua/user/dap.lua
git -C /Users/dancastillo/jasper/weaver-api add .vscode/launch.json
git -C /Users/dancastillo/.config/nvim commit -m "feat: add weaver api node attach profiles to neovim"
git -C /Users/dancastillo/jasper/weaver-api commit -m "feat: add local core-api debug profile"
```

### Task 4: Verify the workflow end-to-end and document it

**Files:**
- Create: `/Users/dancastillo/jasper/weaver-api/docs/guides/neovim-node-debugging.md`
- Modify: `/Users/dancastillo/jasper/weaver-api/README.md`
- Test: `/Users/dancastillo/jasper/weaver-api/apps/core-api/src/main.ts`

**Step 1: Start Core API in the same way developers already do**

Run:

```bash
cd /Users/dancastillo/jasper/weaver-api
pnpm --filter @app/core-api dev
```

Expected: the app compiles, prints `Starting server ...`, and eventually binds the inspect port `9229`.

Then verify the port:

```bash
lsof -nP -iTCP:9229 -sTCP:LISTEN
```

Expected: a `node` process is listening on `127.0.0.1:9229` or `*:9229`.

**Step 2: Manually prove breakpoint binding in Neovim**

1. Open `/Users/dancastillo/jasper/weaver-api` in Neovim, not a random subdirectory.
2. Set a breakpoint in `/Users/dancastillo/jasper/weaver-api/apps/core-api/src/main.ts`.
3. Run `:DapContinue` and choose `Weaver: Core API (9229)`.
4. Trigger code execution that reaches the breakpoint.

Expected: the breakpoint becomes verified and execution stops in the TypeScript source file, not only in compiled JS.

**Step 3: If it fails, capture the right logs immediately**

In Neovim:

```vim
:DapSetLogLevel TRACE
:DapContinue
:DapShowLog
```

Expected: a readable DAP log opens. Save the failing log excerpt in the PR description before changing more config.

**Step 4: Document the exact working flow**

Create `/Users/dancastillo/jasper/weaver-api/docs/guides/neovim-node-debugging.md` with:

- the exact `pnpm --filter @app/core-api dev` command
- the inspect port table you actually support in Neovim
- how to choose `Weaver: Core API (9229)`
- how to use `:DapToggleBreakpoint`, `:DapContinue`, `:DapShowLog`, and `:DapSetLogLevel TRACE`
- one troubleshooting section for:
  - Neovim cannot find `node`
  - the service is not listening on the inspect port
  - breakpoints stay unverified because `outFiles` / source maps are wrong

Add a short link to that guide in `/Users/dancastillo/jasper/weaver-api/README.md` near the existing debugging section.

**Step 5: Commit**

```bash
git -C /Users/dancastillo/jasper/weaver-api add docs/guides/neovim-node-debugging.md README.md
git -C /Users/dancastillo/jasper/weaver-api commit -m "docs: add neovim node debugging guide"
```

## Final Verification Checklist

Run these before calling the work done:

```bash
cd /Users/dancastillo/.config/nvim
stylua init.lua lua/
```

```bash
cd /Users/dancastillo/.config/nvim
nvim --headless "+checkhealth" +qa
```

```bash
cd /Users/dancastillo/jasper/weaver-api
pnpm --filter @app/core-api dev
```

```bash
cd /Users/dancastillo/jasper/weaver-api
lsof -nP -iTCP:9229 -sTCP:LISTEN
```

Manual pass criteria:

- `:DapContinue` offers a working `Weaver: Core API (9229)` choice.
- The session attaches without adapter boot errors.
- A breakpoint in TypeScript source verifies and stops execution.
- `:DapShowLog` is only needed for troubleshooting, not normal use.

## Research References

- `nvim-dap-ui` requires `nvim-nio`: https://github.com/rcarriga/nvim-dap-ui/blob/master/README.md
- `nvim-dap-vscode-js` officially supports `pwa-node` and expects a built `vscode-js-debug`: https://github.com/mxsdev/nvim-dap-vscode-js/blob/main/README.md
- VS Code Node debugging docs for `outFiles`, `skipFiles`, `localRoot`, and `remoteRoot`: https://code.visualstudio.com/docs/nodejs/nodejs-debugging
- `vscode-js-debug` option reference: https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
