local M = {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
}
function M.config()
  local wk = require "which-key"
  wk.add {
    { "<leader>o", group = "opencode" },

    {
      "<leader>oA",
      function()
        require("opencode").ask()
      end,
      desc = "Ask opencode",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask "@cursor: "
      end,
      desc = "Ask opencode about this",
      mode = "n",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask "@selection: "
      end,
      desc = "Ask opencode about selection",
      mode = "v",
    },
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle embedded opencode",
    },
    {
      "<leader>on",
      function()
        require("opencode").command "session_new"
      end,
      desc = "New session",
    },
    {
      "<leader>oy",
      function()
        require("opencode").command "messages_copy"
      end,
      desc = "Copy last message",
    },
    {
      "<S-C-u>",
      function()
        require("opencode").command "messages_half_page_up"
      end,
      desc = "Scroll messages up",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command "messages_half_page_down"
      end,
      desc = "Scroll messages down",
    },
    {
      "<leader>op",
      function()
        require("opencode").select_prompt()
      end,
      desc = "Select prompt",
      mode = { "n", "v" },
    },
    {
      "<leader>oe",
      function()
        require("opencode").prompt "Explain @cursor and its context"
      end,
      desc = "Explain code near cursor",
    },
  }

  -- `opencode.nvim` passes options via a global variable instead of `setup()` for faster startup
  ---@type opencode.Opts
  vim.g.opencode_opts = {
    -- Your configuration, if any — see `lua/opencode/config.lua`
  }

  -- Required for `opts.auto_reload`
  vim.opt.autoread = true
end

return M
