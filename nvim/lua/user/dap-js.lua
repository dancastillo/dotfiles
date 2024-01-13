local M = {
  "mxsdev/nvim-dap-vscode-js",
  event = "VeryLazy",
  dependencies = {
    {
      "mfussenegger/nvim-dap",
    },
  },
}
function M.config()
  local dap = require "dap"
  require("dap-vscode-js").setup {
    node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
    debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",
    -- debugger_cmd = { "extension" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
    adapters = {
      "chrome",
      "pwa-node",
      "pwa-chrome",
      "pwa-msedge",
      "node-terminal",
      "pwa-extensionHost",
      "node",
      "chrome",
    }, -- which adapters to register in nvim-dap
    -- log_file_path = "(stdpath cache)/dap_vscode_js.log", -- Path for file logging
    -- log_file_level = 1, -- Logging level for output to file. Set to false to disable file logging.
    -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
  }

  local js_based_languages = { "typescript", "javascript", "typescriptreact" }

  for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
      -- {
      --   type = "pwa-node",
      --   name = "Launch file",
      --   request = "attach",
      --   address = "localhost",
      --   port = 9229,
      --   restart = true,
      --   localRoot = "${workspaceFolder}",
      --   remoteRoot = "/usr/app",
      --   sourceMaps = true,
      -- },
      -- {
      --   type = "pwa-node",
      --   request = "attach",
      --   name = "Attach",
      --   processId = require("dap.utils").pick_process,
      --   cwd = "${workspaceFolder}",
      -- },
      -- {
      --   type = "pwa-chrome",
      --   request = "launch",
      --   name = 'Start Chrome with "localhost"',
      --   url = "http://localhost:3000",
      --   webRoot = "${workspaceFolder}",
      --   userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
      -- },
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
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
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
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
      },
    }
  end

  local function get_to_line_end(string, idx)
    local newline = string:find("\n", idx, true)
    local to_end = newline and string:sub(idx, newline - 1) or string:sub(idx)
    return to_end, newline
  end

  local function str_rfind(string, idx, needle)
    for i = idx, 1, -1 do
      if string:sub(i, i - 1 + needle:len()) == needle then
        return i
      end
    end
  end

  local function str_splice(string, start_idx, end_idx)
    local new_content = string:sub(1, start_idx - 1)
    if end_idx then
      return new_content .. string:sub(end_idx + 1)
    else
      return new_content
    end
  end

  -- copied from https://github.com/stevearc/overseer.nvim/blob/271760514c2570dc544c45d3ca9754dcf2785a41/lua/overseer/util.lua#L72-L102
  require('dap.ext.vscode').json_decode = function(content)
    local ok, data = pcall(vim.json.decode, content, { luanil = { object = true } })
    while not ok do
      local char = data:match("invalid token at character (%d+)$")
      if char then
        local to_end, newline = get_to_line_end(content, char)
        if to_end:match("^//") then
          content = str_splice(content, char, newline)
          goto continue
        end
      end

      char = data:match("Expected object key string but found [^%s]+ at character (%d+)$")
      char = char or data:match("Expected value but found T_ARR_END at character (%d+)")
      if char then
        local comma_idx = str_rfind(content, char, ",")
        if comma_idx then
          content = str_splice(content, comma_idx, comma_idx)
          goto continue
        end
      end

      error(data)
      ::continue::
      ok, data = pcall(vim.json.decode, content, { luanil = { object = true } })
    end
    return data
  end
  require('dap.ext.vscode').load_launchjs()
  require('dap.ext.vscode').load_launchjs(nil,
    {
      node = {
        ['pwa-node'] = js_based_languages,
        ['node'] = js_based_languages,
        ['chrome'] = js_based_languages,
        ['pwa-chrome'] = js_based_languages,
        -- ['pwa-msedge'] = js_based_languages,
        -- ['pwa-extensionHost'] = js_based_languages,
        -- ['node-terminal'] = js_based_languages

      }
    }
  )

end

return M
