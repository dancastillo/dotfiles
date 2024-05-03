local M = {
  "leon-richardt/comment-highlights.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {},
  cmd = "CHToggle",
  keys = {
    {
      "<leader>cc",
      function()
        require("comment-highlights").toggle()
      end,
      desc = "Toggle comment highlighting",
    },
  },
}

function M.config()
  require("comment-highlights").setup {
    -- The highlight groups to use for the different comment types
    -- The keys are the comment types and the values are the highlight groups
    -- The highlight groups can be any highlight group that is defined in your colorscheme
    -- The default highlight groups are defined in the `default_highlight_groups` table
    highlight_groups = {
      line = "Comment",
      block = "Comment",
      default = "Comment",
    },

    -- The default highlight groups to use for the different comment types
    default_highlight_groups = {
      line = "Comment",
      block = "Comment",
      default = "Comment",
    },

    -- The default comment types to use for the different filetypes
    default_comment_types = {
      -- The keys are the filetypes and the values are the comment types
      -- The comment types can be any of the keys in the `highlight_groups` table
      ["default"] = "default",
    },

    -- The comment types to use for the different filetypes
    -- The keys are the filetypes and the values are the comment types
    -- The comment types can be any of the keys in the `highlight_groups` table
    comment_types = {
      ["default"] = "default",
    },

    -- Whether to use the default comment types for the different filetypes
    use_default_comment_types = true,

    -- Whether to use the default highlight groups for the different comment types
    use_default_highlight_groups = true,

    -- Whether to enable the plugin
    -- If this is false, the plugin will not do anything
    enabled = true,
  }
end

return M
