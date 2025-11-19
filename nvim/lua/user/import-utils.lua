-- Import management utilities
local M = {}

-- Toggle between relative and absolute imports
function M.toggle_import_style()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false
  
  for i, line in ipairs(lines) do
    -- Check for import statements
    if line:match("^import.*from") then
      -- Check if it's a relative import
      if line:match('from ["\']%.') then
        -- Convert to absolute (using tsconfig aliases would need project-specific logic)
        -- This is a simplified version - you'd need to customize based on your aliases
        lines[i] = line:gsub('from ["\']%.', 'from "@/')
        modified = true
      elseif line:match('from ["\']@/') then
        -- Convert back to relative
        lines[i] = line:gsub('from ["\']@/', 'from "./')
        modified = true
      end
    end
  end
  
  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.notify("Import style toggled", vim.log.levels.INFO)
  else
    vim.notify("No imports found to toggle", vim.log.levels.WARN)
  end
end

-- Add keymap for toggling imports
vim.keymap.set('n', '<leader>ti', M.toggle_import_style, { 
  desc = 'Toggle import style (relative/absolute)' 
})

return M