local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
}

local function get_node_path()
  local node_path = vim.fn.exepath "node"
  assert(node_path ~= "", "node executable not found for JavaScript debugging")
  return node_path
end

local function get_workspace_root()
  local buffer_name = vim.api.nvim_buf_get_name(0)
  local search_path = buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.fn.getcwd()
  local root_marker = vim.fs.find({ "pnpm-workspace.yaml", ".git" }, {
    path = search_path,
    upward = true,
  })[1]

  return root_marker and vim.fs.dirname(root_marker) or vim.fn.getcwd()
end

local function get_workspace_out_files()
  local root = get_workspace_root()
  return {
    root .. "/apps/*/dist/**/*.js",
    root .. "/libs/*/dist/**/*.js",
  }
end

local function get_workspace_source_map_locations()
  local root = get_workspace_root()
  return {
    root .. "/**",
    "!" .. root .. "/**/node_modules/**",
  }
end

local function attach_by_port(name, port)
  return {
    name = name,
    type = "pwa-node",
    request = "attach",
    address = "127.0.0.1",
    port = port,
    cwd = get_workspace_root,
    restart = true,
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
    skipFiles = { "<node_internals>/**", "node_modules/**" },
    outFiles = get_workspace_out_files,
    resolveSourceMapLocations = get_workspace_source_map_locations,
  }
end

local M = {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    -- {
    "jay-babu/mason-nvim-dap.nvim",
    -- config = function()
    --   require("mason-nvim-dap").setup {
    --     ensure_installed = {
    --       "js",
    --       "node2",
    --     },
    --   }
    -- end,
    -- },
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "nvim-neotest/nvim-nio",
      },
    },
    {
      "theHamsta/nvim-dap-virtual-text",
    },
    {
      "nvim-telescope/telescope-dap.nvim",
    },
    { "stevearc/overseer.nvim" },
    {
      "mxsdev/nvim-dap-vscode-js",
      dependencies = {
        "microsoft/vscode-js-debug",
        version = '1.x',
        build = "git reset --hard && npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      },
      config = function()
        local dap_js = require "dap-vscode-js"

        ---@diagnostic disable-next-line: missing-fields
        dap_js.setup {
          -- Path of node executable. Defaults to $NODE_PATH, and then "node"
          node_path = get_node_path(),

          -- Path to vscode-js-debug installation.
          debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",

          -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
          -- debugger_cmd = { "js-debug-adapter" },

          -- which adapters to register in nvim-dap
          adapters = {
            "pwa-node",
            "pwa-chrome",
            "pwa-msedge",
            "pwa-extensionHost",
            "node-terminal",
          },

          -- Path for file logging
          -- log_file_path = vim.fn.stdpath "cache" .. "/dap_vscode_js.log",

          -- Logging level for output to file. Set to false to disable logging.
          -- log_file_level = 1,

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
  wk.add {
    { "<leader>dC", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = "Run To Cursor" },
    { "<leader>dU", "<cmd>lua require'dapui'.toggle({reset = true})<cr>", desc = "Toggle UI" },
    { "<leader>db", "<cmd>lua require'dap'.step_back()<cr>", desc = "Step Back" },
    { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue" },
    { "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", desc = "Disconnect" },
    { "<leader>dg", "<cmd>lua require'dap'.session()<cr>", desc = "Get Session" },
    { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into" },
    { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over" },
    { "<leader>dp", "<cmd>lua require'dap'.pause()<cr>", desc = "Pause" },
    { "<leader>dq", "<cmd>lua require'dap'.close()<cr>", desc = "Quit" },
    { "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", desc = "Toggle Repl" },
    { "<leader>ds", "<cmd>lua require'dap'.continue()<cr>", desc = "Start" },
    { "<leader>dt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
    { "<leader>du", "<cmd>lua require'dap'.step_out()<cr>", desc = "Step Out" },
  }

  local dap = require "dap"
  dap.set_log_level "ERROR"

  dap.adapters.node = function(cb, config)
    local adapter = dap.adapters["pwa-node"]
    local node_config = vim.tbl_extend("force", config or {}, { type = "pwa-node" })
    if type(adapter) == "function" then
      adapter(cb, node_config)
      return
    end

    cb(adapter)
  end

  for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
      {
        name = "Attach to existing `node --inspect` process",
        type = "pwa-node",
        request = "attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        restart = true,
        sourceMaps = true,
        protocol = "inspector",
        console = "integratedTerminal",
        skipFiles = {
          '${workspaceFolder}/node_modules/**/*.js',
          '${workspaceFolder}/packages/**/node_modules/**/*.js',
          '${workspaceFolder}/packages/**/**/node_modules/**/*.js',
          '<node_internals>/**',
          'node_modules/**',
        },
        resolveSourceMapLocations = {
          '${workspaceFolder}/**',
          '!**/node_modules/**',
        },
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        -- trace = true, -- include debugger info
        runtimeExecutable = get_node_path(),
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
      attach_by_port("Weaver: Core API (9229)", 9229),
      attach_by_port("Weaver: Task Agent Worker (9249)", 9249),
      -- Divider for the launch.json derived configs
      {
        name = "----- ↓ launch.json configs ↓ -----",
        type = "",
        request = "launch",
      },
    }
  end

  if vim.fn.filereadable ".vscode/launch.json" then
    local dap_vscode = require "dap.ext.vscode"
    local ok, json5 = pcall(require, "json5")
    if ok and type(json5.parse) == "function" then
      dap_vscode.json_decode = json5.parse
    end
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
            id = "watches",
            size = 0.20,
          },
          {
            id = "scopes",
            size = 0.30,
          },
          {
            id = "breakpoints",
            size = 0.30,
          },
          {
            id = "stacks",
            size = 0.20,
          },
        },
        position = "left",
        size = 50,
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
        size = 25,
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
  -- Open Dap UI when attaching or launching a session
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  -- Close Dap UI when the session is terminated or exited
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
end

return M
