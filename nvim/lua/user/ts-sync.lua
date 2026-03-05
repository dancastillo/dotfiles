-- TypeScript LSP sync and diagnostic fixes
local M = {}

-- Restart TypeScript LSP for current buffer
function M.restart_ts_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
  
  for _, client in ipairs(clients) do
    if vim.lsp.buf_is_attached(bufnr, client.id) then
      vim.notify("Restarting TypeScript LSP...", vim.log.levels.INFO)
      client.stop()
      vim.defer_fn(function()
        vim.cmd("edit")
      end, 1000)
      return
    end
  end
  
  vim.notify("No TypeScript LSP client found", vim.log.levels.WARN)
end

-- Clear all TypeScript diagnostics and force refresh
function M.clear_ts_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
  
  for _, client in ipairs(clients) do
    if vim.lsp.buf_is_attached(bufnr, client.id) then
      -- Clear diagnostics
      vim.diagnostic.reset(nil, bufnr)
      
      -- Force file reload
      local params = {
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
      }
      
      client.notify("textDocument/didChange", {
        textDocument = params.textDocument,
        contentChanges = {
          { text = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) }
        }
      })
      
      vim.notify("TypeScript diagnostics cleared", vim.log.levels.INFO)
      return
    end
  end
  
  vim.notify("No TypeScript LSP client found", vim.log.levels.WARN)
end

-- Force TypeScript project reload
function M.reload_ts_project()
  local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
  
  for _, client in ipairs(clients) do
    client.notify("workspace/didChangeConfiguration", {
      settings = client.settings
    })
  end
  
  vim.notify("TypeScript project reloaded", vim.log.levels.INFO)
end

-- Toggle TypeScript diagnostics on/off
local ts_diagnostics_enabled = true
function M.toggle_ts_diagnostics()
  ts_diagnostics_enabled = not ts_diagnostics_enabled
  
  if ts_diagnostics_enabled then
    vim.diagnostic.enable()
    vim.notify("TypeScript diagnostics enabled", vim.log.levels.INFO)
  else
    vim.diagnostic.disable()
    vim.notify("TypeScript diagnostics disabled", vim.log.levels.INFO)
  end
end

-- Force TypeScript refresh on external file changes
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "tsconfig.json", "package.json" },
  callback = function()
    -- Notify TypeScript LSP to reload project configuration
    local clients = vim.lsp.get_active_clients({ name = "ts_ls" })
    for _, client in ipairs(clients) do
      client.notify("workspace/didChangeConfiguration", {
        settings = client.settings or {}
      })
    end
  end,
})

-- Keymaps
vim.keymap.set('n', '<leader>tr', M.restart_ts_lsp, { desc = 'Restart TypeScript LSP' })
vim.keymap.set('n', '<leader>tc', M.clear_ts_diagnostics, { desc = 'Clear TypeScript Diagnostics' })
vim.keymap.set('n', '<leader>tp', M.reload_ts_project, { desc = 'Reload TypeScript Project' })
vim.keymap.set('n', '<leader>td', M.toggle_ts_diagnostics, { desc = 'Toggle TypeScript Diagnostics' })

return M
