local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
}

local M = {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    {
      "jay-babu/mason-nvim-dap.nvim",
      config = function()
        require("mason-nvim-dap").setup {
          ensure_installed = {
            "js",
            "node2",
          },
        }
      end,
    },
    {
      "rcarriga/nvim-dap-ui",
    },
    {
      "theHamsta/nvim-dap-virtual-text",
    },
    {
      "nvim-telescope/telescope-dap.nvim",
    },
    { "stevearc/overseer.nvim" },
    -- Install the vscode-js-debug adapter
    {
      "microsoft/vscode-js-debug",
      -- After install, build it and rename the dist directory to out
      -- build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
      build = "npm install --legacy-peer-deps  && npx gulp vsDebugServerBundle &&  mv dist out",
      version = "1.*",
    },
    {
      "mxsdev/nvim-dap-vscode-js",
      config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("dap-vscode-js").setup {
          -- Path of node executable. Defaults to $NODE_PATH, and then "node"
          node_path = "node",

          -- Path to vscode-js-debug installation.
          -- debugger_path = vim.fn.resolve(vim.fn.stdpath "data" .. "/lazy/vscode-js-debug"),
          debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",

          -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
          -- debugger_cmd = { "js-debug-adapter" },

          -- which adapters to register in nvim-dap
          adapters = {
            "node",
            "pwa-node",
            "chrome",
            "pwa-chrome",
            "pwa-msedge",
            "pwa-extensionHost",
            "node-terminal",
          },

          -- Path for file logging
          -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

          -- Logging level for output to file. Set to false to disable logging.
          -- log_file_level = false,

          -- Logging level for output to console. Set to false to disable console output.
          -- log_console_level = vim.log.levels.ERROR,
        }
      end,
    },
    {
      "Joakker/lua-json5",
      build = "./install.sh",
    },
  },
}

function M.config()
  local wk = require "which-key"
  wk.register {
    ["<leader>dt"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
    ["<leader>dc"] = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
    ["<leader>dC"] = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
    ["<leader>dd"] = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
    ["<leader>dg"] = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
    ["<leader>db"] = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
    ["<leader>di"] = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
    ["<leader>do"] = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
    ["<leader>du"] = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
    ["<leader>dp"] = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
    ["<leader>dr"] = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
    ["<leader>ds"] = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
    ["<leader>dq"] = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
    ["<leader>dU"] = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
  }

  local dap = require "dap"

  -- dap.adapters.node2 = {
  --   type = "executable",
  --   command = "node",
  --   args = { vim.fn.stdpath "data" .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
  -- }

  dap.adapters.node = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
  }

  for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
      -- -- Debug web applications (client side)
      -- {
      --   type = "pwa-chrome",
      --   request = "launch",
      --   name = "Launch & Debug Chrome",
      --   url = function()
      --     local co = coroutine.running()
      --     return coroutine.create(function()
      --       vim.ui.input({
      --         prompt = "Enter URL: ",
      --         default = "http://localhost:3000",
      --       }, function(url)
      --         if url == nil or url == "" then
      --           return
      --         else
      --           coroutine.resume(co, url)
      --         end
      --       end)
      --     end)
      --   end,
      --   webRoot = vim.fn.getcwd(),
      --   protocol = "inspector",
      --   sourceMaps = true,
      --   userDataDir = false,
      -- },
      {
        type = "node",
        name = "Launch",
        request = "launch",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        restart = true,
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      {
        type = "node",
        name = "Attach",
        request = "attach",
        cwd = vim.fn.getcwd(),
        restart = true,
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
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
        restart = true,
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        -- resolveSourceMapLocations = {}
        resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach Pick",
        processId = require("dap.utils").pick_process,
        cwd = vim.fn.getcwd(),
        restart = true,
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
        skipFiles = { "<node_internals>/**", "node_modules/**" },
      },
      -- Divider for the launch.json derived configs
      {
        name = "----- ↓ launch.json configs ↓ -----",
        type = "",
        request = "launch",
      },
    }
  end

  if vim.fn.filereadable ".vscode/launch.json" then
    require("dap.ext.vscode").json_decode = require("overseer.json").decode
    local dap_vscode = require "dap.ext.vscode"
    dap_vscode.load_launchjs(nil, {
      ["node"] = js_based_languages,
      ["pwa-node"] = js_based_languages,
      ["chrome"] = js_based_languages,
      ["pwa-chrome"] = js_based_languages,
    })
  end

  local dapui = require "dapui"
  dapui.setup {
    controls = {
      element = "repl",
      enabled = true,
      icons = {
        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = "",
      },
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = "",
    },
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.25,
          },
          {
            id = "breakpoints",
            size = 0.25,
          },
          {
            id = "stacks",
            size = 0.25,
          },
          {
            id = "watches",
            size = 0.25,
          },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          {
            id = "repl",
            size = 0.5,
          },
          {
            id = "console",
            size = 0.5,
          },
        },
        position = "bottom",
        size = 35,
      },
    },
    mappings = {
      edit = "e",
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t",
    },
    render = {
      indent = 1,
      max_value_lines = 100,
    },
  }
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
end

return M
