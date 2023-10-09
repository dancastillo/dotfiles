--  NOTE: Must happen before plugins are required  otherwise wrong leader will be used
require 'user.options'
require 'user.keymaps'
require 'user.plugins'

require 'user.alpha'
-- require 'user.bufferline'
require 'user.bufdelete'
require 'user.colorscheme'
require 'user.copilot'
require 'user.json5'
require 'user.dap'
require 'user.gitsigns'
require 'user.harpoon'
require 'user.indent-blankline'
-- require 'user.lsp'
require 'user.lspconfig'
require 'user.lualine'
require 'user.navic'
require 'user.netrw'
require 'user.null-ls'
require 'user.nvim-cmp'
require 'user.nvim-tree'
require 'user.nvim-treesitter'
require 'user.project'
require 'user.telescope'
require 'user.whichkey'
require 'user.yank-highlight'

require 'user.extras.colorizer'
require 'user.extras.dressing'
require 'user.extras.fidget'
require 'user.extras.matchup'
require 'user.extras.modicator'
require 'user.extras.navbuddy'
require 'user.extras.noice'
require 'user.extras.rainbow'
require 'user.extras.smoothie'

