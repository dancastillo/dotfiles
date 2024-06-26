local M = {
  "linrongbin16/gitlinker.nvim",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  event = "VeryLazy",
}
-- GitLink: generate git link and copy to clipboard.
-- GitLink!: generate git link and open in browser.
-- GitLink blame: generate the /blame url and copy to clipboard.
-- GitLink! blame: generate the /blame url and open in browser.

function M.config()
  local wk = require "which-key"
  wk.register {
    ["<leader>gy"] = { "<cmd>GitLink! default_branch<cr>", "Git link main" },
    ["<leader>gY"] = { "<cmd>GitLink!<cr>", "Git link" },
    ["<leader>gb"] = { "<cmd>GitLink! blame<cr>", "Git link blame" },
  }

  require("gitlinker").setup {
    -- print message in command line
    message = false,

    -- key mapping
    -- mapping = {
    --   ["<leader>gY"] = {
    --     -- copy git link to clipboard
    --     action = require("gitlinker.actions").clipboard,
    --     desc = "Copy git link to clipboard",
    --   },
    --   ["<leader>gy"] = {
    --     -- open git link in browser
    --     action = require("gitlinker.actions").system,
    --     desc = "Open git link in browser",
    --   },
    -- },

    -- write logs to console(command line)
    console_log = false,
  }
end

return M
