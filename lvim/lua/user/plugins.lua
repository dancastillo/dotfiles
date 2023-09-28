lvim.plugins = {
  "luisiacc/gruvbox-baby",
  -- Coplit
  "github/copilot.vim",
  -- {
  --   "zbirenbaum/copilot.lua",
  --   -- event = { "VimEnter" },
  --   config = function()
  --     vim.defer_fn(function()
  --       require("copilot").setup {
  --         panel = {
  --           enabled = true,
  --           auto_refresh = true,
  --           keymap = {
  --             jump_prev = "[[",
  --             jump_next = "]]",
  --             accept = "<CR>",
  --             refresh = "gr",
  --             open = "<M-CR>"
  --           },
  --           layout = {
  --             position = "bottom", -- | top | left | right
  --             ratio = 0.4
  --           },
  --         },
  --         suggestion = {
  --           enabled = true,
  --           auto_trigger = true,
  --           debounce = 75,
  --           keymap = {
  --             -- accept = "<M-l>",
  --             accept = "<Tab>",
  --             accept_word = false,
  --             accept_line = false,
  --             next = "<M-]>",
  --             prev = "<M-[>",
  --             dismiss = "<C-]>",
  --           },
  --         },
  --         filetypes = {
  --           markdown = false,
  --           help = false,
  --           gitcommit = false,
  --           gitrebase = false,
  --           hgcommit = false,
  --           svn = false,
  --           cvs = false,
  --           ["."] = false,
  --         },
  --         copilot_node_command = "node", -- Node.js version must be > 16.x
  --         server_opts_overrides = {},
  --       }
  --     end, 100)
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end,
  -- },
  {
    "notjedi/nvim-rooter.lua",
    config = function()
      require("nvim-rooter").setup({
        rooter_patterns = { ".git", ".hg", ".svn" },
        trigger_patterns = { "*" },
        manual = false,
      })
    end
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      vim.g.gitblame_enabled = 1
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  "jose-elias-alvarez/typescript.nvim",
  "christoomey/vim-tmux-navigator",
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
  },
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup()
    end
  },
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "mxsdev/nvim-dap-vscode-js",
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "theHamsta/nvim-dap-virtual-text",
  "jackMort/ChatGPT.nvim",
  {
    "Joakker/lua-json5",
    build = "./install.sh"
  },
  "nvim-neotest/neotest",
  "nvim-neotest/neotest-jest",
  "iamcco/markdown-preview.nvim"
}
