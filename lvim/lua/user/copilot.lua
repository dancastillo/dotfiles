-- Copilot
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Copilot)"
table.insert(lvim.builtin.cmp.sources, 1, { name = "copilot" })

-- https://github.com/LunarVim/LunarVim/issues/1856#issuecomment-954224770
-- lvim.keys.insert_mode["<Tab>"] = false
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""
local cmp = require "cmp"

lvim.builtin.cmp.mapping["<Tab>"] = function(fallback)
  -- if cmp.visible() then
  --   cmp.select_next_item()
  -- else
  local copilot_keys = vim.fn["copilot#Accept"]()
  if copilot_keys ~= "" then
    vim.api.nvim_feedkeys(copilot_keys, "i", true)
  else
    fallback()
  end
end
-- end
-- lvim.builtin.cmp.mapping.insert_mode["<Tab>"] = nil
