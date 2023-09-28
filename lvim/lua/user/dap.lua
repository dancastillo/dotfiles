local dap, dapui, dapVscodeJs = require("dap"), require("dapui"), require("dap-vscode-js")

dapVscodeJs.setup {
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = "/Users/dancastillo/.local/share/lvim/mason/packages/vscode-js-debug",
  -- debugger_path = vim.fn.stdpath('data') .. "/lazy/vscode-js-debug",
  -- debugger_cmd = { "js-debug-adapter" },                                                       -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' }, -- which adapters to register in nvim-dap
}

local js_based_languages = { "typescript", "javascript", "typescriptreact" }

for _, language in ipairs(js_based_languages) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",

      -- resolveSourceMapLocations = {}
      resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
    },
    {
      -- type = "node",
      type = "pwa-node",
      request = "attach",
      name = "Debugger - CoreAPI",
      address = "localhost",
      port = 9229,
      restart = true,
      localRoot = "${workspaceFolder}",
      remoteRoot = "/usr/app",
      sourceMaps = true,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require 'dap.utils'.pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Start Chrome with \"localhost\"",
      url = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
      userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir"
    },
    {
      -- use nvim-dap-vscode-js's pwa-node debug adapter
      type = "pwa-node",
      -- attach to an already running node process with --inspect flag
      -- default port: 9222
      request = "attach",
      -- -- allows us to pick the process using a picker
      -- processId = require 'dap.utils'.pick_process,
      -- name of the debug action
      name = "Attach debugger to existing `node --inspect` process",
      -- for compiled languages like TypeScript or Svelte.js
      sourceMaps = true,
      -- resolve source maps in nested locations while ignoring node_modules
      resolveSourceMapLocations = { "${workspaceFolder}/**",
        "!**/node_modules/**" },
      -- path to src in vite based projects (and most other projects as well)
      cwd = "${workspaceFolder}/src",
      -- we don't want to debug code inside node_modules, so skip it!
      skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
    },
    -- only if language is javascript, offer this debug action
    language == "javascript" and {
      -- use nvim-dap-vscode-js's pwa-node debug adapter
      type = "pwa-node",
      -- launch a new process to attach the debugger to
      request = "launch",
      -- name of the debug action you have to select for this config
      name = "Launch file in new node process",
      -- launch current file
      program = "${file}",
      cwd = "${workspaceFolder}",
    } or nil,
  }
end

dap.ext.vscode.load_launchjs(nil,
  {
    ['pwa-node'] = js_based_languages,
    ['node'] = js_based_languages,
    ['chrome'] = js_based_languages,
    ['pwa-chrome'] = js_based_languages,
    -- ['pwa-msedge'] = js_based_languages,
    -- ['pwa-extensionHost'] = js_based_languages,
    -- ['node-terminal'] = js_based_languages
  }
)


-- Dap UI set up
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end

vim.fn.sign_define("DapBreakpoint", lvim.builtin.dap.breakpoint)
vim.fn.sign_define("DapBreakpointRejected", lvim.builtin.dap.breakpoint_rejected)
vim.fn.sign_define("DapStopped", lvim.builtin.dap.stopped)


require("nvim-dap-virtual-text").setup()
