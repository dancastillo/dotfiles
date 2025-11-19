-- Error handling for LSP and other async operations
local M = {}

-- Handle unhandled promise rejections
local original_pcall = pcall
function pcall(...)
  local ok, result = original_pcall(...)
  if not ok and result and type(result) == "string" and result:match("length < 0") then
    -- Silently ignore TypeScript server outlining span errors
    return true, nil
  end
  return ok, result
end

-- Set up global error handlers
vim.schedule(function()
  -- Handle LSP errors gracefully
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    if type(msg) == "string" and msg:match("length < 0") then
      return -- Suppress TypeScript server errors
    end
    return original_notify(msg, level, opts)
  end
end)

return M