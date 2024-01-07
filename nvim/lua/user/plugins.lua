-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- laest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

    {
      'Joakker/lua-json5',
      lazy = false,
      build = './install.sh'
    },

  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim' },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = 'BufEnter',
    cmd = 'Gitsigns',
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    commit = '9637670896b68805430e2f72cf5d16be5b97a22a',
  },
  -- 'gc' to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional 'plugins' for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },

  --  Git blame
  {
    'f-person/git-blame.nvim',
    event = 'BufRead',
    config = function()
      vim.cmd 'highlight default link gitblame SpecialComment'
      vim.g.gitblame_enabled = 1
    end,
  },

  -- Highlight TODO comments
  {
    'folke/todo-comments.nvim',
    event = 'BufRead',
    config = function()
      require('todo-comments').setup()
    end,
  },

  -- Vim Tmux navigator
  'christoomey/vim-tmux-navigator',

  -- A pretty list for showing diagnostics, references, telescope results, quickfix and locations
  -- to help you solve all the trouble your code is causing.
  {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
  },

  -- A telescope.nvim extension that offers intelligent prioritization when selecting files from
  -- your editing history.
  -- As the extension learns your editing habits over time, the sorting of the list is dynamically
  -- altered to prioritize the files you're likely to need.
  {
    'nvim-telescope/telescope-frecency.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'kkharji/sqlite.lua' },
  },

  -- Hop is an EasyMotion-like plugin allowing you to jump anywhere in a document with as few keystrokes
  -- as possible.
  {
    'smoka7/hop.nvim',
    version = '*',
    opts = {},
  },

  'tpope/vim-surround',

  'tpope/vim-repeat',

  'iamcco/markdown-preview.nvim',

  -- Comment out code using gc
  'tpope/vim-commentary',

  -- undo tree
  'mbbill/undotree',

  -- 'github/copilot.vim',
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    -- event = { 'VimEnter' },
  },

  {
    'zbirenbaum/copilot-cmp',
    after = { "copilot.lua" },
    config = function()
      require('copilot_cmp').setup()
    end
  },

  -- Nvim Tree and icons
  'nvim-tree/nvim-tree.lua',
  'nvim-tree/nvim-web-devicons',

  -- Auto close pairs {}[]()
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {} -- this is equalent to setup({}) function
  },

  -- Buffer as tabs like modern IDE
  { 'akinsho/bufferline.nvim',         version = '*',                                      dependencies =
  'nvim-tree/nvim-web-devicons' },


  -- Formatter
  { 'jose-elias-alvarez/null-ls.nvim', commit = '0010ea927ab7c09ef0ce9bf28c2b573fc302f5a7' },

  'ThePrimeagen/harpoon',

  -- Graphql
  '/jparise/vim-graphql',

  -- A simple statusline/winbar component that uses LSP to show your current code context. Named after the Indian satellite navigation system.
  'SmiteshP/nvim-navic',

  -- project.nvim is an all in one neovim plugin written in lua that provides superior project management.
  {
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
  },

  {
    'prichrd/netrw.nvim',
    event = 'VeryLazy',
  },

  {
    'NvChad/nvim-colorizer.lua',
    event = { 'BufReadPost', 'BufNewFile' },
  },

  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
  },

  {
    'j-hui/fidget.nvim',
    branch = 'legacy',
  },

  {
    'andymass/vim-matchup',
  },

  {
    'mawkler/modicator.nvim',
    event = 'BufEnter',
  },

  {
    'SmiteshP/nvim-navbuddy',
    dependencies = {
      'SmiteshP/nvim-navic',
      'MunifTanjim/nui.nvim',
    },
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- 'rcarriga/nvim-notify',
    },
  },

  { 'HiPhish/rainbow-delimiters.nvim' },

  {
    'opalmay/vim-smoothie',
    event = 'VeryLazy',
  },

  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
  },

  'mfussenegger/nvim-dap',

  'mxsdev/nvim-dap-vscode-js',

  {
    'microsoft/vscode-js-debug',
    opt = true,
    run = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out'
  },

  { 'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap'} },

  {
    'notjedi/nvim-rooter.lua',
  },

  'prisma/vim-prisma'
  -- 'rcarriga/nvim-dap-ui',
  -- 'theHamsta/nvim-dap-virtual-text',
  -- 'jackMort/ChatGPT.nvim',
  -- {
  --   'Joakker/lua-json5',
  --   build = './install.sh'
  -- },
  -- 'nvim-neotest/neotest',
  -- 'nvim-neotest/neotest-jest',

}, {})
