local M = {
  "luisiacc/gruvbox-baby",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
}
-- --- This module will load a random colorscheme on nvim startup process.
--
-- local M = {
--   "sainnhe/gruvbox-material",
--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
--   priority = 1000, -- make sure to load this before all the other start plugins
-- }
--
-- -- Colorscheme to its directory name mapping, because colorscheme repo name is not necessarily
-- -- the same as the colorscheme name itself.
-- function M.config()
--   -- foreground option can be material, mix, or original
--   vim.g.gruvbox_material_foreground = "original"
--   --background option can be hard, medium, soft
--   vim.g.gruvbox_material_background = "hard"
--   vim.g.gruvbox_material_enable_italic = 1
--   vim.g.gruvbox_material_better_performance = 1
--
--   vim.cmd [[colorscheme gruvbox-material]]
--   -- vim.o.background = "dark" -- or "light" for light mode
-- end

function M.config()
  -- Example config in Lua
  -- vim.g.gruvbox_baby_function_style = "NONE"
  vim.g.gruvbox_baby_keyword_style = "italic"

  -- Each highlight group must follow the structure:
  -- ColorGroup = {fg = "foreground color", bg = "background_color", style = "some_style(:h attr-list)"}
  -- See also :h highlight-guifg
  -- Example:
  -- vim.g.gruvbox_baby_highlights = { Normal = { fg = "#123123", bg = "NONE", style = "underline" } }

  -- Enable telescope theme
  -- vim.g.gruvbox_baby_telescope_theme = 1

  -- Enable transparent mode
  vim.g.gruvbox_baby_transparent_mode = 0

  -- Load the colorscheme
  vim.cmd [[colorscheme gruvbox-baby]]
  -- vim.o.background = "dark" -- or "light" for light mode
end

return M
