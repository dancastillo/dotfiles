-- Performance optimizations for Neovim
-- Disable unused features
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Optimize for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local file_size = vim.fn.getfsize(vim.fn.expand("%:p"))
    if file_size > 1024 * 1024 then -- 1MB
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.buftype = "nowrite"
      vim.opt_local.wrap = false
    end
  end,
})

-- Lazy loading for heavy operations
vim.defer_fn(function()
  -- Defer non-critical initialization
  require("user.extras.matchup")
  require("user.extras.smoothie")
end, 100)