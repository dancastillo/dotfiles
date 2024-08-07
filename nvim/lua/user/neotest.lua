local M = {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Language specific
    "nvim-neotest/neotest-jest", -- https://github.com/nvim-neotest/neotest-jest
    "nvim-neotest/nvim-nio",
  },
}

function M.config()
  local wk = require "which-key"
  wk.add {
    { "<leader>tD", "<cmd>lua require'neotest'.run.run_last({ strategy = 'dap' })<CR>", desc = "Run Last Test" },
    { "<leader>ta", "<cmd>lua require'neotest'.run.attach()<CR>", desc = "Attach Test" },
    {
      "<leader>td",
      "<cmd>lua require'neotest'.run.run({vim.fn.expand('%'), strategy = 'dap'})<CR>",
      desc = "Debug Test",
    },
    { "<leader>tf", "<cmd>lua require'neotest'.run.run(vim.fn.expand('%'))<CR>", desc = "Test File" },
    { "<leader>tl", "<cmd>lua require'neotest'.run.run_last()<CR>", desc = "Run Last Test" },
    { "<leader>to", "<cmd>lua require'neotest'.output.open()<CR>", desc = "Output Window" },
    { "<leader>tp", "<cmd>lua require'neotest'.output_panel.toggle()<CR>", desc = "Output Panel" },
    { "<leader>ts", "<cmd>lua require'neotest'.run.stop()<CR>", desc = "Test Stop" },
    { "<leader>tt", "<cmd>lua require'neotest'.run.run()<CR>", desc = "Test Nearest" },
    { "<leader>ty", "<cmd>lua require'neotest'.summary.toggle()<CR>", desc = "Summary" },
  }

  require("neotest").setup {
    adapters = {
      require "neotest-jest" {
        -- jestCommand = "./node_modules/.bin/jest",
        -- jestConfigFile = "jest.config.js",
        jestConfigFile = function()
          local file = vim.fn.expand "%:p"
          if string.find(file, "/apps/") then
            return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
          end
          if string.find(file, "/libs/") then
            return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
          end

          return vim.fn.getcwd() .. "/jest.config.ts"
        end,
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      },
    },
  }
end

return M
