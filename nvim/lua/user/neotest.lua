local M = {
  "nvim-neotest/neotest",
  cmd = { "Neotest", "NeotestRun", "NeotestSummary", "NeotestOutput", "NeotestOutputPanel", "NeotestStop" },
  keys = {
    {
      "<leader>tD",
      function()
        require("neotest").run.run_last { strategy = "dap" }
      end,
      desc = "Run Last Test",
    },
    {
      "<leader>ta",
      function()
        require("neotest").run.attach()
      end,
      desc = "Attach Test",
    },
    {
      "<leader>td",
      function()
        require("neotest").run.run { vim.fn.expand "%", strategy = "dap" }
      end,
      desc = "Debug Test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      desc = "Test File",
    },
    {
      "<leader>tl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Run Last Test",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open()
      end,
      desc = "Output Window",
    },
    {
      "<leader>tp",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Output Panel",
    },
    {
      "<leader>ts",
      function()
        require("neotest").run.stop()
      end,
      desc = "Test Stop",
    },
    {
      "<leader>tt",
      function()
        require("neotest").run.run()
      end,
      desc = "Test Nearest",
    },
    {
      "<leader>ty",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Summary",
    },
  },
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
