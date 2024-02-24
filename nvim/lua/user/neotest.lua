local M = {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Language specific
    "nvim-neotest/neotest-jest", -- https://github.com/nvim-neotest/neotest-jest
  },
}

function M.config()
  local wk = require "which-key"
  wk.register {
    ["<leader>tt"] = { "<cmd>lua require'neotest'.run.run()<CR>", "Test Nearest" },
    ["<leader>tf"] = { "<cmd>lua require'neotest'.run.run(vim.fn.expand('%'))<CR>", "Test File" },
    ["<leader>td"] = { "<cmd>lua require'neotest'.run.run({ strategy = 'dap' })<CR>", "Debug Test" },
    ["<leader>ts"] = { "<cmd>lua require'neotest'.run.stop()<CR>", "Test Stop" },
    ["<leader>ta"] = { "<cmd>lua require'neotest'.run.attach()<CR>", "Attach Test" },
    ["<leader>to"] = { "<cmd>lua require'neotest'.output.open()<CR>", "Output Window" },
    ["<leader>tp"] = { "<cmd>lua require'neotest'.output_panel.toggle()<CR>", "Output Panel" },
    ["<leader>ty"] = { "<cmd>lua require'neotest'.summary.toggle()<CR>", "Summary" },
  }

  require("neotest").setup {
    adapters = {
      require "neotest-jest" {
        jestCommand = "./node_modules/.bin/jest",
        jestConfigFile = "jest.config.js",
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      },
    },
  }
end

return M
