-- [[ Configure Telescope ]]
local actions = require 'telescope.actions'

require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--hidden',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    file_ignore_patterns = {
      'node_modules', 'build', 'dist', 'yarn.lock', 'package-lock.json'
    },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
      n = {
        ['<esc>'] = actions.close,
        ['q'] = actions.close,
      }
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
    live_grep = {
      --@usage don't include the filename in the search results
      only_sort_text = true,
    },
    grep_string = {
      only_sort_text = true,
    },
    git_files = {
      hidden = true,
      show_untracked = true,
    },
    colorscheme = {
      enable_preview = true,
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
