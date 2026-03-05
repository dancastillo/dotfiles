local M = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
}

function M.config()
  local lint = require("lint")
  local function js_linters()
    if vim.fn.executable("eslint_d") == 1 then
      return { "eslint_d" }
    end
    return { "eslint" }
  end

  local linters = js_linters()
  lint.linters_by_ft = {
    javascript = linters,
    javascriptreact = linters,
    typescript = linters,
    typescriptreact = linters,
  }

  local group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = group,
    callback = function()
      lint.try_lint()
    end,
  })
end

return M
