-- Setup lsp.
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tsserver" })

local capabilities = require("lvim.lsp").common_capabilities()

require("typescript").setup {
  -- disable_commands = false, -- prevent the plugin from creating Vim commands
  debug = false,     -- enable debug logging for commands
  go_to_source_definition = {
    fallback = true, -- fall back to standard LSP definition on failure
  },
  server = {
    -- pass options to lspconfig's setup method
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = capabilities,
  },
}

-- Set a formatter.
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "prettier", filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" } },
}
--
-- -- Set a linter.
-- -- local linters = require("lvim.lsp.null-ls.linters")
-- -- linters.setup({
-- --   { command = "eslint", filetypes = { "javascript", "typescript" } },
-- -- })


require('neotest').setup({
  adapters = {
    require('neotest-jest')({
      -- jestCommand = "npm test --",
      -- jestConfigFile = "custom.jest.config.ts",
      jestConfigFile = function()
        local file = vim.fn.expand('%:p')
        if string.find(file, "/apps/") then
          return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
        end
        if string.find(file, "/libs/") then
          return string.match(file, "(.-/[^/]+/)src") .. "jest.config.ts"
        end

        return vim.fn.getcwd() .. "/jest.config.ts"
      end,
      env = { CI = true },
      cwd = function(path)
        return vim.fn.getcwd()
      end,
    }),
  }
})
