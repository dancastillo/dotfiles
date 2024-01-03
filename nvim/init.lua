vim.opt.cursorline = true -- highlight the current line
vim.o.number = true
-- vim.lsp.set_log_level("debug")
require 'user.launch'
require 'user.options'
require 'user.keymaps'
-- require 'user.plugins'

-- require 'user.alpha'
-- -- require 'user.bufferline'
-- require 'user.bufdelete'
spec("user.colorscheme")
spec("user.devicons")
spec("user.treesitter")
spec("user.mason")
spec "user.schemastore"
spec "user.lspconfig"

-- require 'user.copilot'
-- require 'user.json5'
-- require 'user.dap'
-- require 'user.gitsigns'
-- require 'user.harpoon'
-- require 'user.indent-blankline'
-- -- require 'user.lsp'
-- require 'user.lspconfig'
-- require 'user.lualine'
-- require 'user.navic'
-- require 'user.netrw'
-- require 'user.null-ls'
-- require 'user.nvim-cmp'
-- require 'user.nvim-tree'
-- require 'user.nvim-treesitter'
-- require 'user.project'
-- require 'user.rooter'
-- require 'user.telescope'
-- require 'user.whichkey'
-- require 'user.yank-highlight'
--
-- require 'user.extras.colorizer'
-- require 'user.extras.dressing'
-- require 'user.extras.fidget'
-- require 'user.extras.matchup'
-- require 'user.extras.modicator'
-- require 'user.extras.navbuddy'
-- require 'user.extras.noice'
-- require 'user.extras.rainbow'
-- require 'user.extras.smoothie'
--

require 'user.lazy'

