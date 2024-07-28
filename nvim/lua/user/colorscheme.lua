local M = {
  "luisiacc/gruvbox-baby",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
}

function M.config()
  vim.g.gruvbox_baby_keyword_style = "italic"

  -- Example:
  -- vim.g.gruvbox_baby_highlights = { Normal = { fg = "#123123", bg = "NONE", style = "underline" } }

  -- Enable telescope theme
  -- vim.g.gruvbox_baby_telescope_theme = 1

  -- Enable transparent mode
  vim.g.gruvbox_baby_transparent_mode = 0

  -- Load the colorscheme
  vim.cmd [[colorscheme gruvbox-baby]]
end

return M

-- local M = {
--   "navarasu/onedark.nvim",
--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
--   priority = 1000, -- make sure to load this before all the other start plugins
-- }
--
-- function M.config()
--   require("onedark").setup {
--     -- Main options --
--     style = "warmer", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
--     transparent = false, -- Show/hide background
--     term_colors = true, -- Change terminal color as per the selected theme style
--     ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
--     cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
--
--     -- toggle theme style ---
--     -- toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
--     -- toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between
--
--     -- Change code style ---
--     -- Options are italic, bold, underline, none
--     -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
--     code_style = {
--       comments = "italic",
--       keywords = "none",
--       functions = "none",
--       strings = "none",
--       variables = "none",
--     },
--
--     -- Lualine options --
--     lualine = {
--       transparent = false, -- lualine center bar transparency
--     },
--
--     -- Custom Highlights --
--     colors = {}, -- Override default colors
--     highlights = {}, -- Override highlight groups
--
--     -- Plugins Config --
--     diagnostics = {
--       darker = true, -- darker colors for diagnostic
--       undercurl = true, -- use undercurl instead of underline for diagnostics
--       background = true, -- use background color for virtual text
--     },
--   }
--
--   vim.cmd [[colorscheme onedark]]
-- end
--
-- return M
